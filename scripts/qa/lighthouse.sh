#!/bin/sh
# Gate: Lighthouse lab run (mobile preset, ads and analytics blocked) on the new page types, en + zh (#63 §1, §7).
# Targets: LCP ≤ 1.8 s · CLS ≤ 0.02 · TBT ≤ 100 ms.
# Usage: python3 -I scripts/qa/serve.py 8781 (repo root) & sh scripts/qa/lighthouse.sh [outdir]
OUT=${1:-/tmp/hte-lighthouse}
BASE=${BASE:-http://127.0.0.1:8781}
mkdir -p "$OUT"
for p in /recipes/pot-brownies/ /zh/recipes/pot-brownies/ /de/recipes/infused-keto-chocolate-avocado-mousse/ /category/desserts/ /zh/category/desserts/ / /zh/ /calculator.html /zh/calculator.html /articles.html /donate.html /cannabis-and-sleep.html /zh/cannabis-and-sleep.html /contact.html; do
  name=$(echo "$p" | tr '/' '_')
  npx --yes lighthouse@13.6.0 "$BASE$p" --quiet --only-categories=performance \
    --blocked-url-patterns='*googlesyndication.com*' --blocked-url-patterns='*googletagmanager.com*' \
    --blocked-url-patterns='*google-analytics.com*' --blocked-url-patterns='*doubleclick.net*' \
    --chrome-flags="--headless=new" --output=json --output-path="$OUT/$name.json" >/dev/null 2>&1
  node -e 'const r=require(process.argv[1]),a=r.audits,ok=(v,l)=>v<=l?"ok":"OVER";
    const lcp=a["largest-contentful-paint"].numericValue/1000,cls=a["cumulative-layout-shift"].numericValue,tbt=a["total-blocking-time"].numericValue;
    console.log(process.argv[2].padEnd(48),"perf",Math.round(r.categories.performance.score*100),"· LCP",lcp.toFixed(2)+"s",ok(lcp,1.8),"· CLS",cls.toFixed(3),ok(cls,0.02),"· TBT",Math.round(tbt)+"ms",ok(tbt,100))' "$(cd "$OUT" && pwd)/$name.json" "$p"
done
