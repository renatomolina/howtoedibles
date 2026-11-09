"""Turn the exported logo SVGs into final, font-free assets in images/brand/.

The browser does the layout (justified HOW TO, ring text, leaf over the i) and export.mjs dumps each
<text> as glyph placeholders. Here every glyph is drawn as a path from the Unbounded variable font.

Usage: python3 _prototype-logo/build_assets.py <export.json> <Unbounded[wght].ttf> <outdir>
Needs: fontTools, rsvg-convert, magick.
"""
import html
import json
import math
import re
import subprocess
import sys
from pathlib import Path

from fontTools.misc.transform import Transform
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

src, font_path, outdir = sys.argv[1], sys.argv[2], Path(sys.argv[3])
outdir.mkdir(parents=True, exist_ok=True)
fonts = {}


def instance(wght):
    if wght not in fonts:
        f = instancer.instantiateVariableFont(TTFont(font_path), {"wght": wght})
        fonts[wght] = (f.getGlyphSet(), f.getBestCmap(), f["head"].unitsPerEm)
    return fonts[wght]


def ntos(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def outline(m):
    fill, glyphs = m.group(1), json.loads(html.unescape(m.group(2)))
    assert glyphs, "empty text run"
    d = []
    for g in glyphs:
        gs, cmap, upm = instance(g["w"])
        name = cmap.get(ord(g["c"]))
        assert name, f"glyph missing from font: {g['c']!r}"
        k = g["s"] / upm
        pen = SVGPathPen(gs, ntos=ntos)
        gs[name].draw(TransformPen(pen, Transform().translate(g["x"], g["y"]).rotate(math.radians(g["r"])).scale(k, -k)))
        d.append(pen.getCommands())
    return f'<path fill="{fill}" d="{"".join(d)}"/>'


GLYPHS = re.compile(r'<g fill="([^"]*)" data-glyphs="([^"]*)"\s*(?:/>|></g>)')
for name, svg in json.loads(Path(src).read_text()).items():
    svg = GLYPHS.sub(outline, svg)
    assert "<text" not in svg and "data-glyphs" not in svg, f"{name}: text left over"
    (outdir / f"{name}.svg").write_text(svg + "\n")
    print(f"{name}.svg  {len(svg) // 1024} KB")


def png(svg, out, w, h=None):
    subprocess.run(["rsvg-convert", "-w", str(w), *(["-h", str(h)] if h else []), "-o", str(outdir / out), str(outdir / svg)], check=True)


for s in (16, 32, 48):
    png("icon.svg", f"favicon-{s}.png", s)
subprocess.run(["magick", *(str(outdir / f"favicon-{s}.png") for s in (16, 32, 48)), str(outdir / "favicon.ico")], check=True)
for s in (16, 48):
    (outdir / f"favicon-{s}.png").unlink()  # only the .ico needs these; keep 32 for <link rel=icon type=image/png>
png("icon.svg", "icon-512.png", 512)
png("apple-touch-icon.svg", "apple-touch-icon.png", 180)
png("logo.svg", "logo.png", 960)
png("og-image.svg", "og-image.png", 1200, 630)
subprocess.run(["magick", str(outdir / "og-image.png"), "-quality", "88", str(outdir / "og-image.jpg")], check=True)
(outdir / "og-image.png").unlink()
(outdir / "apple-touch-icon.svg").unlink()
print("pngs: favicon.ico, favicon-32.png, icon-512.png, apple-touch-icon.png, logo.png, og-image.jpg")
