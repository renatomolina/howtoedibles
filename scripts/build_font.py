#!/usr/bin/env python3
"""Build /fonts/unbounded-800.latin1.woff2 from the upstream Unbounded variable font.

Static 800 instance, subset to Latin-1 plus a few typographic marks, kern + liga only
(decided in "What is the performance budget for the new pages?", #63). CJK headings
fall back through the CSS font stack, so zh needs only the digits and "mg" from here.

Run: python3 scripts/build_font.py   (needs fontTools + brotli; re-run only to change the subset)
"""
import pathlib
import urllib.request

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = pathlib.Path(__file__).resolve().parent.parent
# Pinned so a rebuild is reproducible; bump the commit deliberately.
UPSTREAM = ("https://raw.githubusercontent.com/google/fonts/"
            "8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/unbounded/")
CACHE = ROOT / "tmp" / "fonts"
OUT = ROOT / "fonts" / "unbounded-800.latin1.woff2"

UNICODES = (
    list(range(0x20, 0x7F))            # ASCII
    + list(range(0xA0, 0x100))         # Latin-1 Supplement (incl. ½ ¼ ¾ ·)
    + [ord(c) for c in "–—‘’‚“”„•…€−"]  # + „ ‚ for German quotes in headings ("Ergebnisse für „…“")
)


def fetch(name):
    path = CACHE / name
    if not path.exists():
        CACHE.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(UPSTREAM + urllib.request.quote(name), path)
    return path


def main():
    font = TTFont(fetch("Unbounded[wght].ttf"))
    font = instancer.instantiateVariableFont(font, {"wght": 800}, updateFontNames=True)

    cmap = font.getBestCmap()
    absent = [f"U+{u:04X}" for u in UNICODES if u not in cmap]

    opts = subset.Options()
    opts.layout_features = ["kern", "liga"]
    opts.flavor = "woff2"
    sub = subset.Subsetter(opts)
    sub.populate(unicodes=UNICODES)
    sub.subset(font)

    OUT.parent.mkdir(exist_ok=True)
    font.flavor = "woff2"
    font.save(OUT)
    (OUT.parent / "OFL.txt").write_bytes(fetch("OFL.txt").read_bytes())  # OFL §2: ship the licence

    print(f"{OUT.relative_to(ROOT)}: {OUT.stat().st_size:,} B")
    if absent:
        print("not in the font (fall back to the stack):", " ".join(absent))


if __name__ == "__main__":
    main()
