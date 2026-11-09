"""Merge content/translations/{lang}/*.json into i18n/articles_{lang}.json, then run build_site.rb yourself.

- adds each entry under "articles", replacing the frozen `raw_main` stub (#71) with the same slug, and appends
  new slugs to articles_index.article_order (so they enter the index, sitemap and hreflang);
- puts the `<!-- toc -->` marker where the English body in i18n/articles_en.json has it (after the same number of
  closing </div>/</table>), since the translations were cut from the pre-#71 HTML without it;
- adds the missing "Science" label to articles_index.categories;
- localises internal links in body_html: /x.html → /{lang}/x.html, /recipes/s/ → /{lang}/recipes/s/, / → /{lang}/,
  but only when that page exists for the language (after the merge, all 50 articles do). External links stay as they are.
Usage: python3 -I content/translations/merge.py <repo root> [--check]   (--check: report only, write nothing)
"""
import json
import re
import sys
from pathlib import Path

ROOT, CHECK = Path(sys.argv[1]), "--check" in sys.argv
SCIENCE = {"pt": "Ciência", "es": "Ciencia", "de": "Wissenschaft", "zh": "科学"}

for lang in ("pt", "es", "de", "zh"):
    src = sorted((ROOT / "content/translations" / lang).glob("*.json"))
    if not src:
        continue
    path = ROOT / f"i18n/articles_{lang}.json"
    data = json.loads(path.read_text())
    arts, idx = data["articles"], data["articles_index"]
    new = {p.stem: json.loads(p.read_text()) for p in src}
    known = set(arts) | set(new)
    en = json.loads((ROOT / "i18n/articles_en.json").read_text())["articles"]

    def toc_marker(slug, body):
        if "<!-- toc -->" in body:
            return body
        before = en[slug]["body_html"].split("<!-- toc -->")[0]
        if not before.strip():
            return "<!-- toc -->\n" + body
        # the marker follows a closing tag (a box </div> or a </table>): put it after the same n-th one in the translation
        tag = re.search(r"</(\w+)>\s*$", before)
        assert tag and tag.group(1) in ("div", "table", "ul", "ol", "blockquote"), f"{slug}: marker after {before[-40:]!r}"
        k = before.count(f"</{tag.group(1)}>")
        cut = [m.end() for m in re.finditer(f"</{tag.group(1)}>", body)][k - 1]
        return body[:cut] + "\n\n<!-- toc -->" + body[cut:]

    def local(m):
        href = m.group(1)
        a = re.fullmatch(r"/([a-z0-9-]+)\.html", href)
        r = re.fullmatch(r"/recipes/([a-z0-9-]+)/", href)
        if href == "/":
            href = f"/{lang}/"
        elif a and (a.group(1) in known or (ROOT / lang / f"{a.group(1)}.html").exists()):
            href = f"/{lang}{href}"
        elif r and (ROOT / lang / "recipes" / r.group(1)).is_dir():
            href = f"/{lang}{href}"
        return f'href="{href}"'

    changed = 0
    for slug, e in new.items():
        e["body_html"] = toc_marker(slug, e["body_html"])
        before = e["body_html"]
        e["body_html"] = re.sub(r'href="(/[^"]*)"', local, before)
        changed += before != e["body_html"]
        arts[slug] = e
        if slug not in idx["article_order"]:
            idx["article_order"].append(slug)
    idx["categories"].setdefault("Science", SCIENCE[lang])
    left = sorted({h for e in new.values() for h in re.findall(r'href="(/[^"]*)"', e["body_html"]) if not h.startswith(f"/{lang}/")})
    print(f"{lang}: {len(new)} entries merged ({len(arts)} articles now) · links localised in {changed} · still English targets: {left[:6]}")
    if not CHECK:  # same layout as Ruby's JSON.pretty_generate (empty [] / {} on their own lines), so the diff is only the new entries
        out = json.dumps(data, ensure_ascii=False, indent=2)
        out = re.sub(r'^( *)("[^"\n]+": )\[\]', r'\1\2[\n\n\1]', out, flags=re.M)
        out = re.sub(r'^( *)("[^"\n]+": )\{\}', r'\1\2{\n\1}', out, flags=re.M)
        path.write_text(out)
