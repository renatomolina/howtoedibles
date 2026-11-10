"""One-off: fix the 7 English-source problems the translators found (#44), in i18n/articles_en.json.
Each fix is an exact old → new replacement that must match once. The matching edits to the pt/es/de/zh
translations are made in content/translations/{lang}/ (staged, published together with them).
Usage: python3 -I content/translations/fix_en_2026-11.py <repo root>
"""
import json
import re
import sys
from pathlib import Path

FIXES = [
    ("cannabis-edibles-for-beginners", "body_html",
     "This metabolite is significantly more potent than regular THC and crosses the blood-brain barrier more effectively, which is why edible experiences tend to be more intense and longer-lasting than smoking the same amount of cannabis.",
     "This metabolite is about as potent as THC itself, and eating cannabis produces far more of it than smoking does, which is part of why edible experiences tend to be more intense and longer-lasting than smoking the same amount of cannabis."),
    ("cannabis-and-immune-system", "body_html",
     "Cannabis interacts with the immune system through CB2 receptors on immune cells, acting as an immunomodulator with promising implications for autoimmune conditions.",
     "Cannabis interacts with the immune system through CB2 receptors on immune cells. In lab and animal studies it mostly dampens immune activity, but evidence that it helps autoimmune conditions in people is still limited."),
    ("cannabis-and-pets", "description",
     "proper dosing by weight,", "why dosing should come from your vet,"),
    ("cannabis-and-pets", "excerpt",
     "proper dosing by weight,", "why dosing should come from your vet,"),
    ("cooking-with-cbd-vs-thc", "faq",
     "While the basic technique of infusing fats with cannabinoids is similar for both CBD and THC, there are important differences in how you should use them in the kitchen. CBD is often said to tolerate heat slightly better than THC, although lab evidence for this is limited, and a milder, more earthy flavor that blends well with many dishes. THC is more heat-sensitive and has a stronger, more distinctly cannabis-like flavor. Both should be added to fats like butter or oil, but THC requires more careful temperature management to preserve potency.",
     "The basic technique of infusing fats with cannabinoids is the same for CBD and THC, but there are differences in how you use them in the kitchen. CBD is often said to tolerate heat better than THC, but lab evidence doesn't clearly support that, so treat both with the same care: decarboxylate first, infuse at a low temperature and add the infused fat late in cooking. CBD has a milder, earthier flavor that blends well with many dishes, while THC has a stronger, more distinctly cannabis-like flavor."),
    ("cannabis-and-meditation", "faq",
     "Many experienced practitioners prefer a low-ratio CBD:THC edible, such as 4:1, to get the benefits of both.",
     "Many practitioners prefer a CBD-dominant edible with a little THC, such as 10:1 or 20:1 CBD to THC, to get the benefits of both."),
    ("why-our-calculator-is-the-most-accurate", "body_html",
     "you might eat two thinking you need more. Now you are at 80 mg of actual THC instead of the 100 mg you were planning for, which might sound like a smaller problem than it is.",
     "every dose you plan from that number is wrong: you might cut pieces for a dose you are not actually getting, then eat more to make up for it."),
    ("cannabis-for-seniors", "body_html",
     "It is far too early to claim that cannabis can treat or prevent dementia, the preliminary evidence",
     "It is far too early to claim that cannabis can treat or prevent dementia, but the preliminary evidence"),
]

path = Path(sys.argv[1]) / "i18n/articles_en.json"
data = json.loads(path.read_text())
for slug, field, old, new in FIXES:
    a = data["articles"][slug]
    if field == "faq":
        hits = [q for q in a["faq"] if old in q["answer"]]
        assert len(hits) == 1, f"{slug} faq: {len(hits)} matches"
        hits[0]["answer"] = hits[0]["answer"].replace(old, new)
    else:
        assert a[field].count(old) == 1, f"{slug} {field}: {a[field].count(old)} matches"
        a[field] = a[field].replace(old, new)
    print(f"fixed {slug} [{field}]")
out = json.dumps(data, ensure_ascii=False, indent=2)
out = re.sub(r'^( *)("[^"\n]+": )\[\]', r'\1\2[\n\n\1]', out, flags=re.M)
out = re.sub(r'^( *)("[^"\n]+": )\{\}', r'\1\2{\n\1}', out, flags=re.M)
path.write_text(out + "\n")
