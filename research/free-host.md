# Which free host fits howtoedibles, and what it does with our files (#129)

Researched 2026-11-12 for map #128. Sources are the official Cloudflare, Netlify and GitHub docs and pricing pages, linked inline. Serving behaviour was also **tested locally** with `wrangler` 4.161.0 (`wrangler dev` / `wrangler pages dev`, which run Cloudflare's asset-serving code) against a small fixture shaped like our URLs, and compared with live GitHub Pages using `curl`.

## Answer

**Use Cloudflare Workers with static assets, assets only (no Worker script),** set to `html_handling: "none"` and `not_found_handling: "404-page"`, with the DNS nameservers moved to Cloudflare.

- It is free with no request cap: "Requests to static assets are free and unlimited" ([billing](https://developers.cloudflare.com/workers/static-assets/billing-and-limitations/)). The 100,000-requests-a-day Free cap only counts requests that run a Worker script, and an assets-only Worker never runs one.
- It is the only candidate that can serve our URLs **exactly** as they are today. Cloudflare's default (on both Pages and Workers) redirects every `/x.html` to `/x`. Workers can turn that off; Pages can't.
- Cloudflare itself says "Start new projects with Workers" ([Pages overview](https://developers.cloudflare.com/pages/)).
- Build: Workers Builds (3,000 min/month, Ruby preinstalled, **no Chrome**) works if the og/schema PNGs stay committed. If they don't, build in GitHub Actions (Chrome is preinstalled; $12/month of compute on a private repo, about 2,000 Linux minutes) and deploy with `wrangler deploy`.

Ruled out:
- **Cloudflare Pages:** it 308s every ranking `.html` URL and there is no switch to stop it.
- **Netlify Free:** each production deploy costs 15 of the 300 monthly credits, and when the credits run out it pauses *every* site.
- **GitHub Pages:** it needs GitHub Pro (paid) to publish from a private repo.

## Comparison

| | Cloudflare Workers static assets | Cloudflare Pages | Netlify Free (credit plan) | GitHub Pages via Actions |
|---|---|---|---|---|
| Private repo, free | Yes. Deploy from Actions with `wrangler`, or connect the repo through the Workers Builds GitHub app (you pick which repos) | Yes (Git integration or direct upload) | Personal repos yes. "Private organization repos" only from Pro ([pricing](https://www.netlify.com/pricing/)) | **No**: GitHub Free gets "GitHub Pages in public repositories"; private needs Pro ([plans](https://docs.github.com/en/get-started/learning-about-github/githubs-plans)) |
| Commercial / AdSense | No restriction found | No restriction found | Pricing page doesn't restrict it | Allowed for content sites. Not "to run your online business, e-commerce site" ([limits](https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits)) |
| Files per deploy | 20,000 (Free), wrangler ≥ 4.34 ([limits](https://developers.cloudflare.com/workers/platform/limits/)) | 20,000 (Free) ([limits](https://developers.cloudflare.com/pages/platform/limits/)) | No cap found | Site ≤ 1 GB |
| Max file | 25 MiB | 25 MiB | — | — |
| Bandwidth / requests | Static requests free and unlimited | Unlimited | 20 credits/GB, 2 credits/10k requests, out of 300 credits/month | 100 GB/month soft |
| Deploys / build minutes | Workers Builds: 3,000 min/month, 1 concurrent, 20 min timeout, 2 vCPU / 8 GB ([builds limits](https://developers.cloudflare.com/workers/ci-cd/builds/limits-and-pricing/)) | 500 builds/month, 1 concurrent, 20 min timeout | 15 credits per production deploy. Previews and branch deploys are free ([credits](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/credit-based-pricing-plans/)) | 10-min deploy timeout. Actions: $12/month compute on private repos, public repos free |
| Build image | Ubuntu 24.04, Ruby 3.4.11, Node 24, no Chrome listed ([image](https://developers.cloudflare.com/workers/ci-cd/builds/build-image/)) | Ubuntu 22.04, Ruby 3.4.4, Node 22, no Chrome listed ([image](https://developers.cloudflare.com/pages/configuration/build-image/)) | Ubuntu 24.04, Ruby 3.x, Node 24, no Chrome listed ([software](https://docs.netlify.com/build/configure-builds/available-software-at-build-time/)) | ubuntu-24.04 runner: Ruby 3.2.3 (3.3/3.4/4.0 cached), Node 22, **Chrome 156** ([runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)) |
| `/about.html` | **200 with `html_handling: "none"`** (configurable) | **308 → `/about`**, no opt-out | Pretty URLs (on by default) turns `/about.html` into `/about/`. It can be switched off | 200 |
| Redirects | `_redirects`: 2,000 static + 100 dynamic, 301/302/303/307/308 + 200 proxy; **wins over existing files** | Same | No hard cap. **A file at the path wins** unless the rule ends in `!` | None (meta refresh only) |
| Headers | `_headers`: 100 rules | Same | `_headers` / `netlify.toml` | None; `max-age=600` forced |
| 404 | Nearest `404.html`, status 404, when set to `"404-page"` | Nearest `404.html`. With no root 404.html it falls back to SPA mode | Root `404.html` | Root `404.html` |
| Custom domain | **Nameservers must be on Cloudflare** ("does not support any domain whose nameservers are not managed by Cloudflare", [migration guide](https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/)) | Apex needs a Cloudflare zone; `www` works by CNAME from external DNS ([custom domains](https://developers.cloudflare.com/pages/configuration/custom-domains/)) | CNAME / their DNS | CNAME file + A records |
| Previews | Preview URLs per branch. Builds post a PR comment with the URLs ([GitHub integration](https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/github-integration/)). `wrangler versions upload --preview-alias <name>` from Actions; the last 1,000 aliases are kept ([previews](https://developers.cloudflare.com/workers/configuration/previews/)) | Per branch and PR, branch aliases, `X-Robots-Tag: noindex` ([previews](https://developers.cloudflare.com/pages/configuration/preview-deployments/)) | Unlimited, free | None |

## What each Cloudflare mode does with our URL shapes (local lab, wrangler 4.161.0)

The fixture has `about.html`, `pt/sobre.html`, `recipes/pot-brownies/index.html`, a meta-refresh stub at `desserts/brownies/index.html` plus a `_redirects` 301 for it, `404.html` and `pt/404.html`, and `_headers` for `/fonts/*`. "Live" is www.howtoedibles.com on GitHub Pages today.

| Request | Live GitHub Pages | Workers default (`auto-trailing-slash`) | Pages | **Workers `none` + rules below** |
|---|---|---|---|---|
| `/about.html` | 200 | **307 → /about** | **308 → /about** | 200 |
| `/pt/sobre.html` | 200 | **307 → /pt/sobre** | **308 → /pt/sobre** | 200 |
| `/about` | 200 (duplicate) | 200 | 200 | 404 |
| `/recipes/pot-brownies/` | 200 | 200 | 200 | 200 |
| `/recipes/pot-brownies` | 301 → `/` form | 307 → `/` form | 308 → `/` form | 301 → `/` form (rule) |
| `/recipes/pot-brownies/index.html` | 200 | 307 → dir | 308 → dir | 200 |
| `/index.html` | 200 | 307 → / | 308 → / | 200 |
| `/pt` | 301 → /pt/ | 307 → /pt/ | 308 → /pt/ | 301 → /pt/ (rule) |
| `/desserts/brownies/` (stub file + rule) | 200 meta refresh | **301** | **301** | **301** |
| `/calculator.html?quantity=7&potency=20` (rule) | 200 meta refresh | — | — | 301 → `/edible-dosage-calculator/?quantity=7&potency=20` (query kept) |
| `/pt/nope/` | 404 (`/404.html`) | 404 `pt/404.html` | 404 `pt/404.html` | 404 `pt/404.html` |
| `/fonts/a.woff2` | `max-age=600` | `_headers` applied | `_headers` applied | `_headers` applied |
| HTML default `Cache-Control` | `max-age=600` | `public, max-age=0, must-revalidate` + ETag | same | same |

These are the documented tables in practice ([html_handling](https://developers.cloudflare.com/workers/static-assets/routing/advanced/html-handling/), [Pages route matching](https://developers.cloudflare.com/pages/configuration/serving-pages/)). Under `none`, "only exact file paths resolve", so directory URLs need 200-proxy rules. This is the `_redirects` that produced the right-hand column. Static rules go first, then 5 dynamic proxies plus a few dynamic slash 301s (well under the 100 dynamic limit):

```
/desserts/brownies/   /recipes/pot-brownies/  301   # one line per stub, both slash forms
/desserts/brownies    /recipes/pot-brownies/  301
/calculator.html      /edible-dosage-calculator/ 301
/pt                   /pt/                    301   # also /es /de /zh, /edible-dosage-calculator, …
/recipes/:slug        /recipes/:slug/         301   # also /category/:slug, /:lang/recipes/:slug, /:lang/category/:slug
/                     /index.html             200
/:a/                  /:a/index.html          200
/:a/:b/               /:a/:b/index.html       200
/:a/:b/:c/            /:a/:b/:c/index.html    200
/:a/:b/:c/:d/         /:a/:b/:c/:d/index.html 200
```

Matching is exact on the trailing slash, so `/recipes/:slug` doesn't catch `/recipes/x/`. A placeholder never matches `/`, and a rule like `/:slug` would also catch `/about.html`, because redirects win over files. So **don't** write a generic extensionless → `.html` rule.

If we ever have to stay on Pages, there's a hack that also passed the lab: rename `x.html` to `x.html.html` at deploy (not `index.html` or `404.html`). The default matcher then serves `/x.html` with a 200. It's fragile and undocumented; Workers `none` is the documented route.

## Gotchas for this site

1. **The default 307/308 on every `.html` URL.** About 50 English articles, about 200 translated articles (`/{lang}/{slug}.html`), plus `about`, `contact`, `donate`, `articles` and `calculator` pages per language. Workers needs `html_handling: "none"` set explicitly. Pages can't avoid it.
2. **What changes under `none`.** Extensionless `/about` returns 200 today (a duplicate of `/about.html`) and would become 404. Check GSC for any extensionless URL with clicks. If there are some, add one static 301 per URL; there's room for 2,000. `/index.html` and `/x/index.html` stay 200, as today.
3. **Rails-era stubs become real 301s for free.** `git grep -l 'http-equiv="refresh"'` finds **42 stubs**: 41 `…/index.html` directories plus `calculator.html`. That's about 83 static `_redirects` lines covering both slash forms. Redirects win over files, so the stub HTML can stay during cutover and be deleted afterwards. Query strings are kept.
4. **404.** Set `not_found_handling: "404-page"` explicitly. Otherwise Workers answers unknown paths with an empty 404 (Pages would switch to SPA mode and serve `/` with a 200 if the root `404.html` were ever missing). The nearest-`404.html` lookup means per-language `/{lang}/404.html` files would work later without JS.
5. **Cache headers get worse unless set.** The default is `max-age=0, must-revalidate`. The edge keeps every asset cached until the next deploy and answers repeat requests with 304 via ETag, but browsers revalidate every request (Pages gives 600 s today). `_headers` (100 rules) fixes this. `/fonts/*` can be `immutable`. `/og/*`, `/schema/*` and `/images/*` aren't content-hashed (a re-render keeps the filename), so give them a long `max-age` without `immutable`.
6. **Only upload the site.** Today Pages serves the whole repo (`/CLAUDE.md` answers 200 live). Use `.assetsignore` (Workers doesn't skip `.git`/`node_modules` the way Pages did, [migration guide](https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/)) or build into a `dist/`. Limits: about 6,000 files today against the 20,000 cap, and no file over 5 MB against 25 MiB.
7. **DNS.** Workers custom domains need the zone on Cloudflare nameservers (accepted at charting), and "You cannot create a Custom Domain on a hostname with an existing CNAME" ([custom domains](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/)), so delete the `www` CNAME to `renatomolina.github.io` first.
   - **Apex → www:** Cloudflare doesn't do this the way GitHub Pages does. Add a Single Redirect, 301 with the query string kept ([example](https://developers.cloudflare.com/rules/url-forwarding/examples/redirect-root-to-www/)). The Free plan gets 10 of them ([availability](https://developers.cloudflare.com/rules/url-forwarding/)).
   - **http → https:** handle it separately (the example rule only matches https).
   - **Records:** after the nameserver move, carry over the Search Console TXT and any MX records.
8. **Build at deploy time.** The generator needs only Ruby stdlib (`json fileutils cgi date digest set zlib`), so any Ruby 3.x works. A full `ruby scripts/build_site.rb` took **172 s** on the dev Mac and left **zero diff**, so it's deterministic, well inside the 20-minute timeouts. `render_rasters.mjs` starts Chrome **only when a PNG needs rendering** ("0 of 1672 to render" here), so on a Chrome-less Cloudflare builder the build works as long as `og/` and `schema/` PNGs stay committed. If they don't, render in Actions.
9. **`data/lastmod.json` is build state.** The sitemap's `lastmod` comes from a committed hash-and-date map that the build rewrites (`real_lastmods` in `build_site.rb`). If CI builds without committing it back, every deploy re-dates changed URLs to the deploy day, or to the first-seen day for new ones. The pipeline ticket has to keep it committed (or derive dates from git).
10. **One build at a time per account** on both Cloudflare builders. Parallel sessions pushing branches will queue.
11. **Previews.** Pages documents `X-Robots-Tag: noindex` on previews. I found no equivalent statement for Workers preview URLs (`*.workers.dev`, public by default), so check the header on the first preview, or add `X-Robots-Tag` for preview hosts.
12. **Terms.** Cloudflare's CDN terms limit serving "a disproportionate percentage of pictures" *through the CDN* unless you use the Developer Platform, which is the channel Workers static assets is on ([service terms](https://www.cloudflare.com/service-specific-terms-application-services/)). The terms call it a "Paid Service" without saying how free tiers count. The risk is low for an HTML-first site, but images are 125 of our ~300 MB.
13. **Netlify, for the record.** At 15 credits per production deploy, 300 credits allow at most 20 merges a month with zero traffic. When they run out, "all of your web projects … are paused" ([how credits work](https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/how-credits-work/)). On top of that, redirect matching ignores trailing slashes and a file at the path beats a rule unless forced (`!`), so every stub rule needs `!`.

## GitHub Actions on a private repo

GitHub Free gets "$12 USD per month" of compute, with Linux 2-core at $0.006/min (about 2,000 min, my arithmetic). "If your account does not have a valid payment method on file, usage is blocked once you consume the included compute usage" ([Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)). Public repos are free. At about 3–6 min per build, that's a few hundred deploys a month. The runner has Ruby, Node and Chrome, but not ImageMagick or rsvg; only `build_logo.py` needs those, and it isn't a deploy step.

## Not verified

- Production may differ from the local `wrangler dev` lab: Workers answered 307 locally and Pages 308. Re-run the probe against the first `*.workers.dev` deploy before the DNS flip.
- No doc says outright that the Pages / Workers Builds GitHub app accepts private repos. Deploying with `wrangler` from Actions avoids the question.
- Whether `apt-get install chromium` works inside Workers Builds isn't documented.
- I didn't measure Netlify's file-count limit or our monthly bandwidth; with Netlify out, neither matters.
