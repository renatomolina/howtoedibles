"""Check translated article entries against their English source (content/translations/en/{slug}.json).

Hard failures (exit 1): wrong keys, changed dates, TOC ids/order differ, h2 ids differ, hrefs differ,
structural tag counts differ, wrong category label, related slugs differ, FAQ count differs, still English.
Usage: python3 -I content/translations/validate.py <translations dir> [lang/slug ...]   (no args = everything present)
"""
import collections
import html
import json
import re
import sys
from pathlib import Path

BASE = Path(sys.argv[1])
CATS = {
    "pt": {"Edibles": "Comestíveis", "Health": "Saúde", "Wellness": "Bem-estar", "Culture": "Cultura", "Guides": "Guias", "Science": "Ciência"},
    "es": {"Edibles": "Comestibles", "Health": "Salud", "Wellness": "Bienestar", "Culture": "Cultura", "Guides": "Guías", "Science": "Ciencia"},
    "de": {"Edibles": "Edibles", "Health": "Gesundheit", "Wellness": "Wellness", "Culture": "Kultur", "Guides": "Ratgeber", "Science": "Wissenschaft"},
    "zh": {"Edibles": "食品", "Health": "健康", "Wellness": "养生", "Culture": "文化", "Guides": "指南", "Science": "科学"},
}
READ = {"pt": "{n} min de leitura", "es": "{n} min de lectura", "de": "{n} Min. Lesezeit", "zh": "{n}分钟阅读"}
STRUCT = ["h2", "h3", "h4", "ul", "ol", "li", "a", "table", "tr", "td", "th", "blockquote", "div"]
EN_WORDS = {"the", "and", "with", "your", "that", "of", "to", "is", "for", "this", "are", "you", "can", "it"}


def words(s):
    return html.unescape(re.sub(r"<[^>]+>", " ", s))


def check(lang, slug):
    src = json.loads((BASE / "en" / f"{slug}.json").read_text())
    path = BASE / lang / f"{slug}.json"
    try:
        tr = json.loads(path.read_text())
    except Exception as e:
        return [f"unreadable JSON: {e}"]
    errs = []
    if set(tr) != set(src):
        errs.append(f"keys differ: {sorted(set(tr) ^ set(src))}")
        return errs
    for k in ("date_published", "date_modified"):
        if tr[k] != src[k]:
            errs.append(f"{k} changed")
    if [t["id"] for t in tr["toc"]] != [t["id"] for t in src["toc"]]:
        errs.append("toc ids/order differ")
    b, sb = tr["body_html"], src["body_html"]
    if re.findall(r'<h2 id="([^"]+)"', b) != re.findall(r'<h2 id="([^"]+)"', sb):
        errs.append("h2 ids differ")
    if collections.Counter(re.findall(r'href="([^"]*)"', b)) != collections.Counter(re.findall(r'href="([^"]*)"', sb)):
        errs.append(f"hrefs differ: {sorted((collections.Counter(re.findall(r'href=\"([^\"]*)\"', sb)) - collections.Counter(re.findall(r'href=\"([^\"]*)\"', b))).elements())[:4]}")
    for t in STRUCT:
        n, sn = len(re.findall(rf"<{t}[\s>]", b)), len(re.findall(rf"<{t}[\s>]", sb))
        if n != sn:
            errs.append(f"<{t}> count {n} vs {sn}")
    if re.findall(r'class="([^"]+)"', b) != re.findall(r'class="([^"]+)"', sb):
        errs.append("class attributes differ")
    if tr["category"] != CATS[lang][src["category"]]:
        errs.append(f"category should be {CATS[lang][src['category']]!r}")
    n = re.search(r"\d+", src["read_time"]).group(0)
    if tr["read_time"] != READ[lang].format(n=n):
        errs.append(f"read_time should be {READ[lang].format(n=n)!r}")
    if [r["slug"] for r in tr["related"]] != [r["slug"] for r in src["related"]]:
        errs.append("related slugs differ")
    if len(tr["faq"]) != len(src["faq"]) or any(set(q) != {"question", "answer"} for q in tr["faq"]):
        errs.append("faq shape differs")
    # language: everything a reader sees, minus the Sources section (citation titles stay in their original language)
    visible = re.split(r'<h2 id="sources"', b)[0]
    visible = " ".join([tr["title"], tr["description"], tr["excerpt"], words(visible)] + [q["question"] + " " + q["answer"] for q in tr["faq"]] + [t["text"] for t in tr["toc"]])
    if lang == "zh":
        cjk = len(re.findall(r"[一-鿿]", visible))
        latin = len(re.findall(r"[A-Za-z]{3,}", visible))
        if cjk < 4 * latin:
            errs.append(f"looks untranslated: {cjk} CJK chars vs {latin} Latin words")
    else:
        w = re.findall(r"[^\W\d_]+(?:'[^\W\d_]+)?", visible.lower())  # Unicode letters: "información" is one word
        r = sum(x in EN_WORDS for x in w) / max(1, len(w))
        if r > 0.03:
            errs.append(f"looks partly English: {r:.1%} English function words")
        src_vis = " ".join([src["title"], src["description"], src["excerpt"], words(re.split(r'<h2 id="sources"', sb)[0])] + [q["question"] + " " + q["answer"] for q in src["faq"]] + [t["text"] for t in src["toc"]])
        ratio = len(w) / max(1, len(re.findall(r"[^\W\d_]+(?:'[^\W\d_]+)?", src_vis.lower())))
        if not 0.8 <= ratio <= 1.7:
            errs.append(f"length ratio {ratio:.2f} vs English (something dropped or duplicated?)")
    return errs


targets = sys.argv[2:] or [f"{p.parent.name}/{p.stem}" for p in sorted(BASE.glob("[a-z][a-z]/*.json")) if p.parent.name != "en"]
bad = 0
for t in targets:
    lang, slug = t.split("/")
    errs = check(lang, slug)
    bad += bool(errs)
    print(("✗ " if errs else "✓ ") + t + ("  " + " | ".join(errs) if errs else ""))
print(f"{len(targets) - bad}/{len(targets)} ok")
sys.exit(1 if bad else 0)
