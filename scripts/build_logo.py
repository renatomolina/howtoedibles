#!/usr/bin/env python3
"""Build the logo assets in images/brand/ and the root icons from one geometry.

The logo is the owner's model (chef toque in orange outline, handlebar mustache, a cannabis leaf as the beard,
"HOW TO" over "EDIBLES"), redrawn as vectors: variant A + favicon F1, picked on prototype/logo-v2.
Text is drawn as paths from the pinned Archivo Black, so every output is font-free (works as <img>, favicon, raster).

Outputs: images/brand/logo.svg, logo-dark.svg (only HOW TO differs: build_redesign.rb turns it into var(--ink)),
logo.png (publisher.logo), og-image.jpg (the generic share card), favicon.ico, favicon_385_icon.ico,
apple-touch-icon.png.

Run: python3 scripts/build_logo.py   (needs fontTools, rsvg-convert, magick), then ruby scripts/build_site.rb
"""
import pathlib
import subprocess
import urllib.request

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
UPSTREAM = ("https://raw.githubusercontent.com/google/fonts/"
            "8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/archivoblack/ArchivoBlack-Regular.ttf")  # pinned, OFL
FONT = ROOT / "tmp" / "fonts" / "ArchivoBlack-Regular.ttf"
BRAND = ROOT / "images" / "brand"

INK, INK_DARK, ORANGE, GREEN, WHITE = "#1f1410", "#f7ede6", "#f5821f", "#79ab47", "#fff"  # the model's orange and green

# ---- symbol, box 0 0 100 164 (the model's 350 × 570 px symbol × 0.2857) ----
HAT = ('<circle cx="18" cy="39" r="14.5"/><circle cx="50" cy="26" r="22"/>'
       '<circle cx="82" cy="40" r="14.5"/><rect x="28" y="37" width="44" height="52"/>')
# left half of the mustache: centre bottom → lobe → curled tip → back over the top to the centre notch (mirrored below)
MUS_L = [(50, 99), (44, 103, 36, 105, 28, 103), (20, 101, 13, 97, 9.5, 91.5), (6.5, 86.5, 7.5, 81, 12, 80.5),
         (15.5, 80, 17.5, 83.5, 15, 86), (19.5, 87, 23, 85, 27, 82), (34, 77, 44, 78.5, 50, 85)]
# leaflets from (50, 113.5): angle from straight down (positive = to the left), length, half-width
LEAFLETS = [(0, 50, 8.4), (50, 43, 7.6), (-50, 43, 7.6), (96, 26, 5.2), (-96, 26, 5.2), (180, 10, 2.6)]


def n(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def mustache(fill):
    m, cs = MUS_L[0], MUS_L[1:]
    mirror = lambda p: [100 - v if i % 2 == 0 else v for i, v in enumerate(p)]
    d = f"M{n(m[0])} {n(m[1])}" + "".join("C" + " ".join(map(n, c)) for c in cs)
    ends = [m] + [c[4:] for c in cs]
    for i in range(len(cs) - 1, -1, -1):  # the same curve backwards, mirrored: controls swapped, to the previous point
        c = cs[i]
        d += "C" + " ".join(map(n, mirror([c[2], c[3], c[0], c[1], *ends[i]])))
    return f'<path fill="{fill}" d="{d}Z"/>'


def leaf(fill):
    return "".join(
        f'<path fill="{fill}" transform="translate(50 113.5) rotate({a})" '
        f'd="M0 0C{n(w)} {n(l * .24)} {n(w)} {n(l * .58)} 0 {n(l)}C{n(-w)} {n(l * .58)} {n(-w)} {n(l * .24)} 0 0Z"/>'
        for a, l, w in LEAFLETS)


def symbol(sw=5.8, orange=ORANGE, green=GREEN, inside=WHITE):
    # the toque is drawn twice (fat stroke, then fill on top), so only the union's outer outline shows
    return (f'<g fill="{orange}" stroke="{orange}" stroke-width="{n(sw * 2)}" stroke-linejoin="round">{HAT}</g>'
            f'<g fill="{inside}">{HAT}</g>{mustache(orange)}{leaf(green)}')


# ---- text as paths ----
font = TTFont(FONT) if FONT.exists() else None


def text_path(s, x, baseline, size, sx, fill):
    """One line as a single path: `size` px, glyphs widened horizontally by sx (so HOW TO matches EDIBLES' width)."""
    gs, cmap, upm = font.getGlyphSet(), font.getBestCmap(), font["head"].unitsPerEm
    k, pen, cx = size / upm, SVGPathPen(gs, ntos=n), x
    for ch in s:
        g = cmap[ord(ch)]
        gs[g].draw(TransformPen(pen, (k * sx, 0, 0, -k, cx, baseline)))
        cx += gs[g].width * k * sx
    return f'<path fill="{fill}" d="{pen.getCommands()}"/>'


def width(s):
    gs, cmap = font.getGlyphSet(), font.getBestCmap()
    return sum(gs[cmap[ord(c)]].width for c in s) / font["head"].unitsPerEm  # in em


def wordmark(x, w, mid, ink, orange):
    """HOW TO over EDIBLES, both `w` wide, centred on y=mid (the model: centred on hat + mustache)."""
    size = w / width("EDIBLES")
    cap = size * font["OS/2"].sCapHeight / font["head"].unitsPerEm
    gap = cap * 0.24
    top = mid - (2 * cap + gap) / 2
    return (text_path("HOW TO", x, top + cap, size, width("EDIBLES") / width("HOW TO"), ink) +
            text_path("EDIBLES", x, top + 2 * cap + gap, size, 1, orange))


def lockup(ink, orange=ORANGE, green=GREEN):
    return symbol(orange=orange, green=green) + wordmark(133, 298, 82, ink, orange)


def svg(view_box, body, w=None, h=None):
    size = f' width="{w}" height="{h}"' if w else ""
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view_box}"{size} role="img" aria-label="HowToEdibles">{body}</svg>\n'


def png(svg_path, out, w, h=None):
    subprocess.run(["rsvg-convert", "-w", str(w), *(["-h", str(h)] if h else []), "-o", str(out), str(svg_path)], check=True)


def main():
    global font
    if not FONT.exists():
        FONT.parent.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(UPSTREAM, FONT)
        font = TTFont(FONT)
    tmp = ROOT / "tmp" / "logo"
    tmp.mkdir(parents=True, exist_ok=True)

    LOGO_BOX = "0 0 432 164"
    (BRAND / "logo.svg").write_text(svg(LOGO_BOX, lockup(INK)))
    (BRAND / "logo-dark.svg").write_text(svg(LOGO_BOX, lockup(INK_DARK)))
    png(BRAND / "logo.svg", BRAND / "logo.png", 960)

    # F1: the chef alone on white, heavier outline so it survives 16 px
    icon = svg("-32 0 164 164", f'<rect x="-32" width="164" height="164" rx="30" fill="#fff"/>{symbol(sw=9)}')
    (tmp / "icon.svg").write_text(icon)
    for s in (16, 32, 48):
        png(tmp / "icon.svg", tmp / f"favicon-{s}.png", s)
    subprocess.run(["magick", *(str(tmp / f"favicon-{s}.png") for s in (16, 32, 48)), str(ROOT / "favicon.ico")], check=True)
    (ROOT / "favicon_385_icon.ico").write_bytes((ROOT / "favicon.ico").read_bytes())
    # iOS rounds the corners itself: full-bleed white
    (tmp / "apple.svg").write_text(svg("-42 -10 184 184", f'<rect x="-42" y="-10" width="184" height="184" fill="#fff"/>{symbol(sw=7)}'))
    png(tmp / "apple.svg", ROOT / "apple-touch-icon.png", 180)

    # generic share card: the logo on white, as in the model, with the site's two jobs under it
    tag = "Cannabis recipes · dosage calculator"
    s = 34
    tag_w = width(tag) * s
    og = (f'<rect width="1200" height="630" fill="#fff"/><g transform="translate({n(600 - 432 * 1.9 / 2)} 120) scale(1.9)">{lockup(INK)}</g>'
          f'{text_path(tag, 600 - tag_w / 2, 520, s, 1, "#6a5a50")}')
    (tmp / "og.svg").write_text(svg("0 0 1200 630", og, 1200, 630))
    png(tmp / "og.svg", tmp / "og.png", 1200, 630)
    subprocess.run(["magick", str(tmp / "og.png"), "-quality", "88", str(BRAND / "og-image.jpg")], check=True)
    print("images/brand/logo.svg, logo-dark.svg, logo.png, og-image.jpg; favicon.ico, favicon_385_icon.ico, apple-touch-icon.png")


if __name__ == "__main__":
    main()
