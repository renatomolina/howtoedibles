"""Pull the 22 untranslated English articles out of the hand-maintained root pages into the
i18n/articles_{lang}.json entry shape, as translation sources: content/translations/en/{slug}.json.

body_html = the article column minus the TOC block, the "Read more articles" button and the related cards
(build_article_page renders those from `toc` / `related`). The FAQ comes from the page's FAQPage JSON-LD.
Usage: python3 -I content/translations/extract_en.py <repo root>
"""
import html
import json
import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1])
OUT = ROOT / "content/translations/en"
OUT.mkdir(parents=True, exist_ok=True)
SLUGS = ["cannabis-and-alcohol", "cannabis-and-drug-testing", "cannabis-and-exercise", "cannabis-and-gut-health",
         "cannabis-and-immune-system", "cannabis-and-meditation", "cannabis-and-pets", "cannabis-and-pregnancy",
         "cannabis-and-ptsd", "cannabis-dinner-party", "cannabis-edibles-for-beginners", "cannabis-edibles-for-chronic-pain",
         "cannabis-for-seniors", "cannabis-terpenes-explained", "cannabis-tolerance-breaks", "cooking-with-cbd-vs-thc",
         "entourage-effect", "how-to-read-cannabis-labels", "indica-vs-sativa-edibles", "traveling-with-cannabis-edibles",
         "vegan-cannabis-edibles-guide", "why-our-calculator-is-the-most-accurate"]


def text(s):
    return html.unescape(re.sub(r"<[^>]+>", "", s)).strip()


def one(pattern, s, flags=re.S):
    m = re.search(pattern, s, flags)
    assert m, pattern
    return m.group(1)


for slug in SLUGS:
    page = (ROOT / f"{slug}.html").read_text()
    lds = [json.loads(t) for t in re.findall(r'<script type="application/ld\+json">(.*?)</script>', page, re.S)]
    art = next(j for j in lds if j.get("@type") == "Article")
    faq = next((j for j in lds if j.get("@type") == "FAQPage"), {"mainEntity": []})
    col = one(r'<article class="article-body">\s*<div class="container">\s*<div class="row">\s*<div class="col-lg-8[^"]*">(.*?)</article>', page)
    toc_block = one(r'(<!-- Table of Contents -->\s*<div class="article-toc">.*?</div>)', col)
    toc = [{"id": i, "text": text(t)} for i, t in re.findall(r'<a href="#([^"]+)">(.*?)</a>', toc_block)]
    related = [{"slug": h, "title": text(t), "description": text(d)} for h, t, d in re.findall(
        r'<h5 class="card-title"><a href="/([a-z0-9-]+)\.html">(.*?)</a></h5>\s*<p class="card-text">(.*?)</p>', col, re.S)]
    body = col.replace(toc_block, "")
    body = re.split(r'\s*<div class="text-center mt-5 mb-5">', body)[0]  # button + related cards + closing divs
    body = re.sub(r'\n {10}', "\n", body).strip()
    entry = {
        "title": text(one(r"<h1[^>]*>(.*?)</h1>", page)),
        "description": html.unescape(one(r'<meta name="description" content="([^"]*)"', page)),
        "keywords": html.unescape(one(r'<meta name="keywords" content="([^"]*)"', page)),
        "category": text(one(r'class="article-category"[^>]*>(.*?)<', page)),
        "excerpt": text(one(r'class="article-excerpt"[^>]*>(.*?)</', page)),
        "date_published": art["datePublished"][:10],
        "date_modified": art["dateModified"][:10],
        "read_time": text(one(r'class="article-meta"[^>]*>.*?(\d+\s*min read)', page)),
        "toc": toc,
        "body_html": body,
        "faq": [{"question": q["name"], "answer": q["acceptedAnswer"]["text"]} for q in faq["mainEntity"]],
        "related": related,
    }
    # every TOC id must be an h2 in the body, or build_article_page links to nothing
    ids = set(re.findall(r'<h2 id="([^"]+)"', body))
    missing = [t["id"] for t in toc if t["id"] not in ids]
    assert not missing, f"{slug}: toc ids without h2: {missing}"
    (OUT / f"{slug}.json").write_text(json.dumps(entry, ensure_ascii=False, indent=1) + "\n")
    print(f"{slug:42} {len(text(body).split()):5} words · toc {len(toc)} · faq {len(entry['faq'])} · related {len(related)} · {entry['category']} · {entry['read_time']}")
