#!/bin/sh
# Throwaway: Lighthouse (same settings as scripts/qa/lighthouse.sh) on each variant's category and home pages.
# Serve with gzip like Pages: python3 -I tmp/wayfinder/gzserve.py <repo> 8789 & BASE=http://127.0.0.1:8789 sh _prototype-catphoto/lh.sh
BASE=${BASE:-http://127.0.0.1:8789}
OUT=$(dirname "$0")/shots/lh
mkdir -p "$OUT"
for v in ${V:-0 a b c}; do for p in ${P:-en-desserts zh-desserts en-international en-home}; do
  npx --yes lighthouse@13.6.0 "$BASE/_prototype-catphoto/$v/$p.html?shot" --quiet --only-categories=performance \
    --blocked-url-patterns='*googlesyndication.com*' --blocked-url-patterns='*googletagmanager.com*' \
    --blocked-url-patterns='*google-analytics.com*' --blocked-url-patterns='*doubleclick.net*' \
    --chrome-flags="--headless=new" --output=json --output-path="$OUT/$v-$p.json" >/dev/null 2>&1
  node -e 'const r=require(process.argv[1]),a=r.audits,d=a["lcp-breakdown-insight"].details.items[1]||{};
    const lcp=a["largest-contentful-paint"].numericValue/1000;
    console.log(process.argv[2].padEnd(20),"LCP",lcp.toFixed(2)+"s",lcp<=1.8?"ok  ":"OVER","· CLS",a["cumulative-layout-shift"].numericValue.toFixed(3),"·",Math.round(a["total-byte-weight"].numericValue/1024)+" KB ·",(d.selector||"?").slice(0,48))' "$(cd "$OUT" && pwd)/$v-$p.json" "$v $p"
done; done
