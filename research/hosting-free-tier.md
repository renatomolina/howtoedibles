# Free host for howtoedibles.com: Cloudflare Pages vs Workers static assets vs Netlify vs GitHub Pages

Research for #129 (map #128). Checked 2026-11-12 against official docs and pricing pages; every fact cites a source by number (see [Sources](#sources)).
On top of the docs, I ran Cloudflare's local runtime (`wrangler` 4.161.0, `wrangler dev` and `wrangler pages dev`) on a fixture that copies this site's URL shapes, and I curled the live site to get the GitHub Pages baseline. Those results are marked **[tested]**. Local emulation is not production: repeat the probe on a `workers.dev` deploy before the DNS flip.

## What the site needs (measured in the repo)

- 6,037 tracked files and ~315 MB, of which `images/` is 125 MB and `og/` 89 MB. The largest file is `sitemap.xml` at 1.3 MB. 1,272 directory URLs (`…/index.html`) and 268 other `.html` files. Directories go at most 4 levels deep (`/categories/desserts/recipes/brownies/`).
- Build: `scripts/build_site.rb` uses only the Ruby stdlib (`json`, `fileutils`, `cgi`, `date`, `digest`, `set`, `zlib`). `.ruby-version` says **2.7.6**. `scripts/render_rasters.mjs` needs only Node (global `fetch` and `WebSocket`) plus a Chrome binary; it defaults to the macOS Chrome path and reads `CHROME`.
- About 50 commits reached `master` in the last 30 days, so expect about 50 production deploys a month plus previews.
- GitHub Pages today **[tested, live]**:
  - `/about.html` → 200
  - `/about` → 200 (the same file)
  - `/recipes/pot-brownies/` → 200
  - `/recipes/pot-brownies` → 301 to the slashed URL
  - `/pt` → 301 to `/pt/`
  - `/index.html` → 200
  - unknown paths → 404 with `/404.html`
  - every file sends `cache-control: max-age=600`
  - the apex `howtoedibles.com` → 301 to `https://www.howtoedibles.com/`
  - `/CLAUDE.md` → 200, because the whole repo is public

## Comparison

| | **Cloudflare Workers + static assets** | **Cloudflare Pages** | **Netlify (credit plan)** | **GitHub Pages via Actions** |
|---|---|---|---|---|
| Private repo, free | Yes. Git integration through the Cloudflare GitHub app [14], or deploy from Actions with `wrangler-action` [15] | Yes. Git integration or Direct Upload [11][12] | Pricing lists "Private organization repos" under Pro only; the Free plan has one member and no seats [20][22] | **No.** GitHub Free gets "GitHub Pages in public repositories" only; Pro adds Pages for private repos [26] |
| Commercial use / AdSense | No non-commercial clause in the Developer Platform terms, which say it "can be used to host content" [30] | Same as Workers [30] | No non-commercial clause in the ToU or AUP [23][24] | Not allowed "to run your online business", plus a soft bandwidth cap [25] |
| Files per deploy / max file | 20,000 per version / 25 MiB [3] | 20,000 / 25 MiB [9]; Wrangler upload 20,000 / 25 MiB [12] | No per-deploy file cap in the docs I checked | 1 GB site [25] |
| Requests / bandwidth | Static asset requests "free and unlimited" [4]. The 100k/day limit is for Worker *script* invocations [3]; no script here | "free and unlimited" for static [10] | **300 credits/month, hard cap.** 15 credits per production deploy, 20 per GB, 2 per 10k requests [21]. When credits run out, **every project is paused** until the next cycle [22] | 100 GB/month soft limit [25] |
| Builds | Workers Builds: 3,000 min/month, 1 concurrent, 20 min timeout, Ubuntu 24.04 [16][17] | 500 builds/month, 1 concurrent, 20 min timeout [9] | Deploys are metered in credits, not build minutes [22] | Actions: GitHub Free includes **$12/month of compute** (= 2,000 min at $0.006 on Linux 2-core); usage is blocked without a payment method [27] |
| Host build image: Ruby | Default 3.4.11; obeys `.ruby-version` [17] | v3 image: Ruby 3.4.4 by default, obeys `.ruby-version` [13] | `3.x`, obeys `.ruby-version` [19] | Runner has Ruby 3.2.3 and Node 22 [28] |
| Host build image: Chrome | **Not listed** (apt packages include `libgbm1` but no browser) [17] | Not listed [13] | Not listed [19] | **Google Chrome 156 preinstalled** [28] |
| `/about.html` | Default `auto-trailing-slash`: **307 → `/about`**. With **`html_handling: "none"`: 200** [1] **[tested]** | **308 → `/about`, no switch** [7] **[tested]** | Pretty URLs on by default: 301 → `/about` and rewrites `<a>` links [18][29]. Pretty URLs off: serves `/about.html` and `/about` [29] | 200 **[tested]** |
| `/recipes/x/` and `/recipes/x` | Default: 200 / 307 → slash. With `none`: both 404 unless `_redirects` rewrites them (see below) [1] **[tested]** | 200 / 308 → slash **[tested]** | 200 / 301 → slash [29] | 200 / 301 **[tested]** |
| Custom 404 | `not_found_handling: "404-page"` serves the nearest `404.html` with status 404. The default is `"none"` [2][5] | Nearest `404.html` automatically. Without a top-level `404.html` it switches to SPA mode [7] | `_redirects` 404 rules [18] | `404.html` [38] |
| `_redirects` | 2,000 static + 100 dynamic, 1,000 chars each; 301/302/303/307/308 and 200 rewrites; the **default code is 302**; rules "are always followed, regardless of whether or not an asset matches" [6] | Same limits [8][9] | No count limit stated. An existing file **shadows** a rule unless you use `!` [18] | none |
| `_headers` | 100 rules, 2,000 chars per line. Default `Cache-Control: public, max-age=0, must-revalidate` [5] | 100 rules [9]; same default [7] | yes | none (fixed `max-age=600`) |
| Custom domain | Needs the zone on Cloudflare nameservers ("does not support any domain whose nameservers are not managed by Cloudflare") [2]. Apex→www needs a Redirect Rule plus a proxied placeholder record [31] | Apex needs CF nameservers; `www` alone can be an external CNAME [32] | External DNS works (apex A `75.2.60.5` or ALIAS); Netlify adds apex+www as a pair [33] | current setup |
| TLS | Automatic certificate per Custom Domain [31] | Automatic [32] | Automatic [33] | automatic |
| Branch previews | `wrangler preview`: one per branch, URL `<preview>-<worker>.<sub>.workers.dev` with `X-Robots-Tag: noindex`; Free plan **100 previews per Worker**, 100 deploys each [34]. Builds posts a PR comment [14] | Every branch/PR, alias `<branch>.<project>.pages.dev`, `X-Robots-Tag: noindex` [11] | "Unlimited deploy previews"; previews and branch deploys use no credits [20][21] | none |
| Cloudflare's direction | "Start new projects with Workers" [35] | Still maintained; v1 images are moved to v3 on 2026-09-15 [13] | – | – |

## Can Workers serve our URLs unchanged? Yes, with `none` + 5 rewrites **[tested]**

The default `auto-trailing-slash` would **307** every ranking `.html` URL to an extensionless one, and Pages does the same with a **308** and no switch. That rules out both defaults.
With `html_handling: "none"`, `/about.html` is served as-is, but `/recipes/x/` no longer finds `recipes/x/index.html` [1]. `_redirects` 200 rules put directory indexes back.
In local `wrangler dev`, this config gave the same status codes as live GitHub Pages for every path in the probe. The only difference is `/about`, which returns 404 instead of a duplicate 200:

```jsonc
// wrangler.jsonc
{ "name": "howtoedibles", "compatibility_date": "2026-11-01",
  "assets": { "directory": "./dist", "html_handling": "none", "not_found_handling": "404-page" } }
```

```txt
# dist/_redirects. Static rules first (Rails stubs as real 301s; code is 302 if omitted)
/calculator.html /edible-dosage-calculator/ 301
/pt /pt/ 301
# directory indexes: one rule per depth (the site is at most 4 deep)
/ /index.html 200
/:a/ /:a/index.html 200
/:a/:b/ /:a/:b/index.html 200
/:a/:b/:c/ /:a/:b/:c/index.html 200
/:a/:b/:c/:d/ /:a/:b/:c/:d/index.html 200
# slash-less directory → 301, ONLY with literal prefixes (see gotcha 2)
/recipes/:slug /recipes/:slug/ 301
/pt/recipes/:slug /pt/recipes/:slug/ 301
```

Probe results with that config:

| Path | Result |
|---|---|
| `/` | 200 |
| `/index.html` | 200 |
| `/about.html` | 200 |
| `/recipes/foo/` | 200 |
| `/pt/recipes/foo/` | 200 |
| `/recipes/foo` | 301 → `/recipes/foo/` |
| `/pt` | 301 → `/pt/` |
| `/nope` | 404 with the root `404.html` body |
| `/css/site.css` | 200 |
| `/ads.txt` | 200 |
| `/_redirects` | 404 (the file isn't served) |

These rules invoke no Worker script, so they don't touch the 100k/day request limit [5].

Pages can be bent the same way **[tested]**. For each `.html` file, the pair `/about.html /about 200` + `/about /about.html 301` returns 200 on `/about.html`. That costs two static rules per `.html` file (~536 today, out of 2,000) and has to grow with every new article.

## Recommendation

**Cloudflare Workers with static assets, built and deployed from GitHub Actions on a private repo.**

- It is the only free option that is private, allows ads, and can serve every current URL with the same status code without per-file rules.
- Cloudflare now points new projects to Workers rather than Pages [35].
- Static traffic is free and unlimited [4].
- 20,000 files and 25 MiB per file leave 3× headroom over the current file count [3].
- Uploads send only changed files [36].
- Build in Actions rather than Workers Builds:
  - Workers Builds has Ruby but no Chrome.
  - The Actions runner has Chrome 156 preinstalled, plus Ruby and Node [28].
  - The $12 of included compute ≈ 2,000 Linux minutes a month [27]. At ~50 production runs + ~50 preview runs a month, each run can take up to ~20 minutes.
- Deploy with `cloudflare/wrangler-action` [15]. Per branch, run `wrangler preview` (noindex `workers.dev` URL, 100 per Worker on Free [34]).
- Move the nameservers to Cloudflare, which the owner already accepted.

The ranking of the others:

- **Netlify Free is out:** about 50 production deploys × 15 credits = 750, which is more than the 300-credit hard cap even with zero traffic. When the cap is hit, the whole site shows "Site not available" until the next cycle [21][22].
- **GitHub Pages via Actions** would stop the commits of build output but keeps the repo public (private needs Pro) [26]. It is the fallback if Cloudflare goes wrong.
- **Cloudflare Pages** works, but only with the per-file rule workaround.

## Gotchas that would bite this site

1. **Default HTML handling changes URLs.** On Workers the default `auto-trailing-slash` 307s `/about.html` → `/about` and `/recipes/x/index.html` → `/recipes/x/` [1]. Set `"html_handling": "none"`. Pages has no such switch [7].
2. **`_redirects` rules fire even when a file exists** [6]. A generic slash-less rule like `/:lang/recipes/:slug` also caught `/images/recipes/brownies.jpg` and 301'd it to `…brownies.jpg/` **[tested]**, which would break the image-search traffic the old photos are kept for. Use literal prefixes (`/recipes/`, `/pt/recipes/`, `/category/`, …) for slash-less 301s. Generic patterns are only safe with a trailing slash. Stay under 100 dynamic rules.
3. **The `_redirects` default code is 302** [6]. Write `301` explicitly on every Rails-era stub. Because rules win over files, the ~42 meta-refresh stub files can become static 301 lines and be deleted (2,000 static rules available).
4. **`not_found_handling` defaults to `"none"`**, which returns a bare 404 [2]. Set `"404-page"` so the root `404.html` (language picked from the path) is served with a 404 status. With no `404.html` in a subfolder, the root one is the "nearest" [5].
5. **Upload a `dist/` folder, not the repo root.** Workers does not auto-exclude `.git` or `node_modules` (`.assetsignore` is needed) [2]. Deploying `dist/` also ends today's exposure of `/CLAUDE.md`, `/scripts/` and `/content/`. `_redirects` and `_headers` must sit inside `dist/` [6][5].
6. **The DNS move is mandatory, and the apex needs its own rule.** Workers Custom Domains require a Cloudflare-managed zone, and a Custom Domain cannot be created on a hostname that already has a CNAME [2][31]. Today the apex 301s to `www` on GitHub. On Cloudflare that takes a Redirect Rule plus a proxied `A 192.0.2.0` for the apex [31]. Check Namecheap for CAA records before the move [32].
7. **Cache headers start at `max-age=0, must-revalidate`** [5], stricter than GitHub's 600 s. Set long caching for `/fonts/*`, `/og/*`, `/schema/*`, `/images/*` and versioned CSS/JS in `_headers` (max 100 rules). Two rules that both set `Cache-Control` get **joined** into conflicting directives; use `! Cache-Control` to detach first [5].
8. **`.ruby-version` = 2.7.6.** Every host image honours it [13][17][19] and would try to install an EOL Ruby. The scripts are stdlib-only, so bumping to 3.x is likely harmless, but run the build once on 3.x before the switch.
9. **Chrome path.** `render_rasters.mjs` defaults to `/Applications/Google Chrome.app/…`; on the runner set `CHROME` (the readme lists Chrome 156 but not its path, so check it with `which google-chrome` in the first run) [28]. Once PNGs are no longer committed, keep `og/` and `schema/` in the Actions cache (10 GB per repo [27]) or the incremental render becomes a full render on every run.
10. **Duplicate hosts.** The production `*.workers.dev` URL serves the same pages as `www`. Disable `workers_dev` or add a `_headers` rule for that host with `X-Robots-Tag: noindex` (the docs show this exact pattern [5]). Previews on `workers.dev` already send noindex [34].
11. **Version skew.** HTML and assets can come from different versions right after a deploy [4]. That's harmless here because file names aren't hashed, but don't delete a file in the same deploy that stops linking it if a cached page may still request it.
12. **If Pages is chosen anyway:** Browser Integrity Check can't be turned off on Pages and 403s default library user-agents (Python `urllib`, for example) [37]. External monitors and scripted checks need a real User-Agent. Workers on your own zone doesn't have this limit [37].

## Not verified

- Production behaviour of the `_redirects` rewrites under `html_handling: "none"`: tested only in local `wrangler dev`. The cutover plan should run this probe against the `workers.dev` deploy.
- Real Actions minutes per run (full build + incremental raster render + gates) haven't been measured yet; that's for the pipeline/stack ticket.
- Netlify per-deploy file and `_redirects` limits: not found in the docs checked. Not needed, since the credit cap already rules Netlify out.

## Sources

1. Workers, HTML handling (tables for all four modes): https://developers.cloudflare.com/workers/static-assets/routing/advanced/html-handling/
2. Workers, Migrate from Pages (feature matrix, nameserver requirement, `.assetsignore`, explicit 404 handling): https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/ ; `assets` config options and defaults: https://developers.cloudflare.com/workers/wrangler/configuration/#assets
3. Workers, Platform limits (20,000 files / 25 MiB, 100k requests/day): https://developers.cloudflare.com/workers/platform/limits/
4. Workers static assets, Billing and limitations ("free and unlimited", version skew): https://developers.cloudflare.com/workers/static-assets/billing-and-limitations/
5. Workers static assets, Headers (defaults, 100 rules, joining, detach, workers.dev example): https://developers.cloudflare.com/workers/static-assets/headers/ ; SSG and custom 404 (routing diagram, only script invocations are billable): https://developers.cloudflare.com/workers/static-assets/routing/static-site-generation/
6. Workers static assets, Redirects: https://developers.cloudflare.com/workers/static-assets/redirects/
7. Pages, Serving Pages (route matching, 404, SPA fallback, headers): https://developers.cloudflare.com/pages/configuration/serving-pages/
8. Pages, Redirects: https://developers.cloudflare.com/pages/configuration/redirects/
9. Pages, Limits: https://developers.cloudflare.com/pages/platform/limits/
10. Pages Functions pricing (static asset requests free): https://developers.cloudflare.com/pages/functions/pricing/
11. Pages, Preview deployments: https://developers.cloudflare.com/pages/configuration/preview-deployments/
12. Pages, Direct Upload (Wrangler 20,000 files / 25 MiB): https://developers.cloudflare.com/pages/get-started/direct-upload/
13. Pages, Build image (v3 versions, auto-migration dates): https://developers.cloudflare.com/pages/configuration/build-image/
14. Workers Builds, GitHub integration (app install, PR comments): https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/github-integration/
15. Workers, GitHub Actions (`cloudflare/wrangler-action`): https://developers.cloudflare.com/workers/ci-cd/external-cicd/github-actions/
16. Workers Builds, Limits & pricing: https://developers.cloudflare.com/workers/ci-cd/builds/limits-and-pricing/
17. Workers Builds, Build image: https://developers.cloudflare.com/workers/ci-cd/builds/build-image/
18. Netlify, Redirect options (shadowing, trailing slash, Pretty URLs default): https://docs.netlify.com/manage/routing/redirects/redirect-options/
19. Netlify, Available software at build time: https://docs.netlify.com/build/configure-builds/available-software-at-build-time/
20. Netlify, Pricing: https://www.netlify.com/pricing/
21. Netlify, Credit-based pricing plans (credit costs, start 2025-09-04, previews unmetered): https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/credit-based-pricing-plans/
22. Netlify, Billing FAQ (pause behaviour, no extra credits on Free): https://docs.netlify.com/manage/accounts-and-billing/billing/billing-for-credit-based-plans/billing-faq-for-credit-based-plans/
23. Netlify, Terms of Use: https://www.netlify.com/legal/terms-of-use/
24. Netlify, Acceptable Use Policy: https://www.netlify.com/legal/acceptable-use-policy/
25. GitHub Pages limits: https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits
26. GitHub's plans (Pages in public repos on Free, private on Pro): https://docs.github.com/en/get-started/learning-about-github/githubs-plans
27. GitHub Actions billing ($12 included on Free, $0.006/min Linux, 10 GB cache): https://docs.github.com/en/billing/concepts/product-billing/github-actions
28. GitHub-hosted runner image, Ubuntu 24.04 (Chrome 156, Ruby 3.2.3, Node 22): https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md
29. Netlify Support Guide, trailing slash and Pretty URLs (staff guide, reviewed July 2025): https://answers.netlify.com/t/support-guide-how-can-i-alter-trailing-slash-behaviour-in-my-urls-will-enabling-pretty-urls-help/31191
30. Cloudflare, Developer Platform service-specific terms: https://www.cloudflare.com/service-specific-terms-developer-platform/
31. Workers, Custom Domains (zone required, certificates, www↔apex redirect): https://developers.cloudflare.com/workers/configuration/routing/custom-domains/
32. Pages, Custom domains (apex needs CF nameservers, CNAME for subdomain, CAA): https://developers.cloudflare.com/pages/configuration/custom-domains/
33. Netlify, External DNS: https://docs.netlify.com/manage/domains/configure-domains/configure-external-dns/
34. Workers, Previews (per-branch, noindex on workers.dev, Free limits): https://developers.cloudflare.com/workers/previews/ ; Version URLs: https://developers.cloudflare.com/workers/configuration/previews/
35. Cloudflare Pages docs landing ("Start new projects with Workers"): https://developers.cloudflare.com/pages/
36. Workers static assets, Direct Upload (manifest; unchanged files not re-uploaded): https://developers.cloudflare.com/workers/static-assets/direct-upload/
37. Pages, Known issues (Browser Integrity Check): https://developers.cloudflare.com/pages/platform/known-issues/
38. GitHub Pages, Custom 404 page: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site
