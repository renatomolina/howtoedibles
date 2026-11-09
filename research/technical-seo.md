# Technical SEO defects: howtoedibles.com

Research ticket #41, part of map #39. Audit date: 2026-11-08. Covers the repo at `master` @ `359e8a11` and the live site. The live site matches HEAD: `recipes/cannabutter/index.html` and `sitemap.xml` return the same byte counts live as in the repo.

**Hard constraint (from #39):** no change may harm current traffic. Every fix below has a **Risk** line. Most fixes are additive: they add files, add CSS, or correct data on pages Google already treats as broken. The few that touch ranking pages are marked, with a safe way to roll them out.

## How this was checked

- **Static crawl of all ~1,200 HTML pages in the working tree** (old_rails/, data/ and scripts/ excluded). It parsed title, meta description, canonical, hreflang, `<h1>`, JSON-LD, internal links and `<img>`, then resolved every internal URL against the tree using GitHub Pages rules: `foo` serves `foo.html`, and `dir` redirects to `dir/`.
- **Sitemap check:** every `<loc>` and every `xhtml:link` was checked against the tree and against each page's canonical.
- **Live probes with `curl`:** HTTP→HTTPS, apex→www, trailing slash, 404 status, legacy URLs, and publicly served non-site files.
- **Wayback Machine CDX index** (`web.archive.org/cdx/search/cdx?url=howtoedibles.com/*`) to list URLs that returned 200 in the past (1,203 page paths). These were diffed against the current tree.
- **Image inspection:** JPEG dimensions and byte sizes read from file headers; files viewed by eye.
- **Not available:** Search Console and CrUX/PageSpeed field data. The PSI API returned 429 with no key. Items that need that data are marked **[verify in GSC]**.

## Ranked defects (by likely impact on English search)

| # | Defect | Severity | Fix risk |
|---|--------|----------|----------|
| 1 | Pending deletion of `/edible-dosage-calculator/` redirect (the calculator's URL for years) | **High (if shipped)** | None: just don't ship it |
| 2 | ~45 Rails-era URLs return 404 since the March 2026 static migration | **High** (depends on backlinks) | None (adds new URLs only) |
| 3 | Recipe images: 203/236 are text-on-gradient placeholders; the 30 real photos are 260×173, below Google's 50K-pixel minimum | **High** for recipe rich results / Images | Low |
| 4 | Ad unit injected above the hero image and H1 with no reserved space (CLS) | **Medium** [verify in GSC CWV] | None for SEO (CSS only) |
| 5 | Missing image files: default `og:image` and calculator `Article.image` (`/images/pot-brownies.jpg`) return 404; `infused-condensed-milk.jpg` is missing | **Medium** | None |
| 6 | Recipe JSON-LD data quality (HTML entities, `48.0 servings`, wrong dates, no `recipeCuisine`) | **Medium-Low** | Low |
| 7 | Sitemap `lastmod` hardcoded, so Google will ignore it; 88 translated article URLs missing | **Low** | None |
| 8 | Internal link hygiene: `http://` links with 2 redirect hops, one 404 link, 102 broken `/xx/xx/articles.html` links (non-EN) | **Low** | None |
| 9 | hreflang: correct except English `/articles.html`, which has no return links | **Low** | None |
| 10 | Breadcrumb level 2 points at `/?search=Category` (not a real page) | **Low** | Low |
| 11 | Non-site files publicly served (old_rails/, scripts, CLAUDE.md, *.py); legacy DB credentials exposed | **Low SEO / security** | None if done as described |
| 12 | Homepage and calculator.html both titled for "Edible Dosage Calculator" (possible cannibalization) | **Unknown** [verify in GSC] | **High**: do not touch without data |
| — | FAQPage markup on 1,386 pages | Info: produces no rich results, harmless | Do nothing |

What is **not** a defect:
- **Canonicals:** every page has exactly one self-referencing canonical that resolves. The only exceptions are the redirect stub (correct) and the 404 pages.
- **HTTPS/www:** both are enforced by 301s.
- **404s:** missing URLs return a real 404 status.
- **Titles and descriptions:** no exact duplicate titles or meta descriptions among the 237 English recipes, or anywhere else in the English tree.
- **Mobile:** viewport meta is present.
- **Images and CLS:** card and hero images get fixed heights from CSS, so they cause no layout shift.
- **Page weight is small:** homepage HTML ≈26 KB gzipped, Bootstrap CSS 24 KB gzipped, `styles.css` 13 KB gzipped, recipe images median 14 KB.

---

### 1. Do not ship the deletion of `edible-dosage-calculator/index.html` — High

**Evidence:**
- The Rails app served this URL as a public page: `old_rails/app/views/public_pages/edible_dosage_calculator.erb` via the `get '*public_page'` route.
- Wayback snapshots show it returning **200 in 2022, 2023, 2024, 2025 and on 2026-02-09**, the month before the static migration.
- It was the site's calculator URL for years. Calculator pages are the kind of page other sites link to, so it is the most likely holder of external links on the domain.
- Commit `f6fb2241` (2026-03-04) replaced it with an instant meta refresh to `/calculator.html` plus a canonical.

**What Google does with it today:** Google "interprets instant `meta refresh` redirects as permanent redirects" ([Redirects and Google Search](https://developers.google.com/search/docs/crawling-indexing/301-redirects)). So today the old URL's signals are being forwarded to `/calculator.html`. Live: `/edible-dosage-calculator` → 301 → `/edible-dosage-calculator/` (200, meta refresh) → `/calculator.html`.

**If the deletion ships:**
- The URL starts returning 404.
- Google's site-move guidance says to keep redirects "for as long as possible, generally at least 1 year… to move all signals, including links from other sites", and from users' perspective "indefinitely" ([Site moves with URL changes](https://developers.google.com/search/docs/crawling-indexing/site-move-with-url-changes)).
- The redirect has been live for only 8 months. Removing it stops forwarding any external links and bookmarks to `/calculator.html`, which is likely the site's most valuable page.

**Fix:**
- Discard the uncommitted deletion in the main checkout: `git checkout -- edible-dosage-calculator/index.html`.
- Keep the stub permanently.
- **[verify in GSC]** Links report: external links to `/edible-dosage-calculator`. Page indexing: its status.

**Risk:** none. Shipping the deletion is the risky move.

### 2. Rails-era URLs now 404 — High (scaled by backlinks)

**Evidence:** 45 page paths that Wayback recorded as 200 now 404 on the current tree. Spot-checked live:

| Group | Count | Examples |
|---|---|---|
| Old canonical recipe URL format (`get 'categories/:category_slug/recipes/:recipe_slug/'` in `old_rails/config/routes.rb`) | 20 | `/categories/desserts/recipes/pot-brownies`, `/categories/essentials/recipes/cannabutter`, `/categories/desserts/recipes/gummy-bears` (live in Wayback as late as 2026-01-09) |
| Old friendly_id slugs (`friendly_id :name, use: [:slugged, :history]`) | 6 under `/recipes/` | `/recipes/butter`, `/recipes/whiskey`, `/recipes/chai`, `/recipes/popcorn`, `/recipes/eggnog`, `/recipes/grilled-cheese` |
| Short and old category paths | ~16 | `/desserts/brownies`, `/essentials/butter`, `/drinks/chai`, `/honey`, `/butter`, `/coconut-oil`, `/crackers` |
| Old pages | — | `/about`, `/hiring` |

The full list can be regenerated from the CDX query above.

**Why it matters:** links pointing at these URLs used to reach real recipe pages. Now they hit 404s, so any equity they carried is lost. Google says not to send old URLs to non-existent pages, and to return 404 only for content you are intentionally dropping (site-move doc above).

**Fix:**
- Add instant meta-refresh stubs, the same pattern as `edible-dosage-calculator/index.html`: `dir/index.html` with `<meta http-equiv="refresh" content="0;url=…">` plus `<link rel="canonical">`.
- Each stub points to the **equivalent** recipe, e.g. `/categories/desserts/recipes/pot-brownies/` → `/recipes/pot-brownies/` and `/recipes/butter/` → `/recipes/cannabutter/`.
- Prioritize URLs that GSC "Not found (404)" or the Links report shows have value **[verify in GSC]**. The 20 `/categories/…/recipes/…` URLs are the obvious first batch.

**Risk:** none to current pages; stubs only add URLs that 404 today.
- Do **not** point unmatched URLs (e.g. `/hiring`, `/about`) at the homepage. Google says many-to-one redirects to an irrelevant page "might be treated as a soft 404". Let those stay 404.
- GitHub Pages cannot send real 301s. The meta-refresh stub is the only option, and Google treats it as permanent.

### 3. Recipe images are placeholders or too small — High for recipe search features

**Evidence** (from JPEG headers in `images/recipes/`):

| Group | Count | Details |
|---|---|---|
| Placeholders (800×500, 8–22 KB) | 203 of 236 | A pastel gradient, a category icon and the recipe name as text. Includes **103 of the legacy (id ≤ 140) recipes**, e.g. `pot-brownies`, `infused-ghee`, `cannabis-hot-chocolate`, `weed-rice-krispie-treats`. |
| Real photos at 260×173 | 30 | e.g. cannabutter, pot-cookies, gummy-bears. 260×173 ≈ 45K pixels. |
| Real photos at larger sizes | 3 | e.g. 600×900 |
| Missing | 1 | `infused-condensed-milk` has no image file (see #5) |

Google's requirements ([Recipe structured data](https://developers.google.com/search/docs/appearance/structured-data/recipe)):
- `image` is one of only two required Recipe properties.
- "Images must represent the marked up content."
- Google recommends "multiple high-resolution images (minimum of 50K pixels…)" in 16x9, 4x3 and 1x1 ratios.

A placeholder graphic does not represent the dish. The 30 real photos are each below the 50K-pixel minimum. Recipe rich results, the recipe carousel and Google Images depend heavily on the image.

**Fix:**
- Real photos of at least 1200 px wide, served at the existing URL `/images/recipes/{slug}.jpg`. That way no HTML or JSON-LD has to change.
- Optionally list 16x9, 4x3 and 1x1 crops in `image` as an array (in `build_site.rb`).
- Start with the legacy recipes that earn impressions **[verify in GSC]**.

**Risk:** low. Swapping a file at the same URL changes no URLs or text. AI-generated photos that misrepresent a dish would breach the same "represent the content" rule, so review them. The scaled-content question about the March batch belongs to the policy-risk ticket, not this one.

### 4. Ad slot above the fold with no reserved space — Medium [verify in GSC Core Web Vitals]

**Evidence:**
- Every recipe page puts `<div class="ad-container"><ins class="adsbygoogle" data-ad-format="auto" data-full-width-responsive="true">` **before** the hero image and the H1. Source: the generated `recipes/*/index.html`, e.g. `recipes/cannabutter/index.html` lines 373–381.
- The homepage puts one between the H1 and the recipe grid (`index.html` line 283).
- `css/styles.css` has no rule for `.ad-container` or `.adsbygoogle`, so the slot starts at 0 px. It pushes the hero, H1 and ingredients down when the ad fills.

**Google guidance** ([Optimize CLS, web.dev](https://web.dev/articles/optimize-cls)):
- Good CLS is ≤ 0.1 at p75.
- Space for ads should be reserved "in the initial layout", e.g. with `min-height`.
- "Dynamically injected content closer to the top of the viewport usually causes greater layout shifts."

**Fix:** reserve space with CSS only, e.g. `.ad-container { min-height: 280px; }` on mobile. Tune it to the sizes AdSense actually serves. First check the GSC Core Web Vitals report (mobile) to see whether CLS is already failing.

**Risk:** none for SEO. Moving the ad below the H1 would help more but affects AdSense revenue, which #39 puts out of scope. That trade-off is the owner's call.

### 5. Missing image files referenced by metadata — Medium

**Evidence:**
- `https://www.howtoedibles.com/images/pot-brownies.jpg` returns **404**. `images/` contains only `404.*`, `howtoedibleslogo.png`, `missing_recipe.jpg` and `recipes/`.
- That URL is still the default `og:image`/`twitter:image` (from `build_head` in `scripts/build_site.rb` line 205, and the hand-maintained heads). It appears on English `index.html`, `calculator.html`, `contact.html`, `donate.html` and `404.html`, and on every translated non-recipe page.
- It is also the `image` of the `Article` JSON-LD on `calculator.html`.
- `images/recipes/infused-condensed-milk.jpg` does not exist. The recipe's JSON-LD `image` (a **required** property) and five English pages (`index.html` plus four recipe pages) reference it, in all five languages.

**Fix:**
- Add a real `/images/pot-brownies.jpg`, or point the default at an existing image.
- Add `infused-condensed-milk.jpg`.

**Risk:** none.

### 6. Recipe JSON-LD data quality — Medium-Low

These all come from `build_recipe_page` in `scripts/build_site.rb` (lines 1243–1290):

- **HTML entities inside JSON-LD (14 English recipes, plus pt/zh copies).** For example, cannabutter has `"&frac12; cup water"` and `"7 ground&nbsp;weed"`. JSON-LD is not HTML-decoded, so the entities reach Google as literal text. The cannabutter ingredient also has no unit: "7 ground weed".
- **`recipeYield` is a float string** (`"48.0 servings"`) on 41 English recipes. Google: "Specify the number of servings… with just a number." Emit an integer, e.g. `["48", "48 servings"]`.
- **Inaccurate dates.**
  - `datePublished` is hardcoded to `2024-06-01` for every recipe with id ≤ 140. Wayback shows these recipes live since 2018–2019, e.g. `/categories/desserts/recipes/pot-brownies` on 2019-07-01.
  - `dateModified` is hardcoded to `2026-03-15`, but every recipe page was regenerated with new links and markup on 2026-06-25 (commit `359e8a11`).
  - Use real dates: first-seen dates for legacy recipes, and the git date of the last content change.
- **Missing recommended `recipeCuisine`.** It is easy to derive for the International category.
- **No `aggregateRating`/`video`.** Do **not** add ratings without a real rating system, because fabricated reviews violate Google's structured-data policies.

**Risk:** low. Data corrections on existing markup; no URL or visible text change.

### 7. Sitemap — Low

The sitemap is valid: 1,368 URLs, 1.16 MB, every `<loc>` resolves, matches its page's canonical and carries reciprocal `xhtml:link` alternates. The problems:

- **`lastmod` is hardcoded in `build_sitemap`** (`scripts/build_site.rb` lines 1831, 1853, 1856, 1862). Recipes say `2026-03-15`, everything else `2026-06-25`. Note the line `lastmod = r["id"].to_i <= 140 ? "2026-03-15" : "2026-03-15"`.
  - Recipes changed after 2026-03-15.
  - Articles only had template/analytics changes on 2026-06-25, which Google says do not count as significant.
  - Google "uses the `<lastmod>` value if it's consistently and verifiably accurate" ([Build a sitemap](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap)). These values aren't, so they are almost certainly being ignored.
  - Fix: derive from `git log -1 --format=%cs -- <source files>`.
- **88 indexable translated articles are not in the sitemap:** 22 articles × pt/es/de/zh, e.g. `/de/cannabis-and-alcohol.html`. Their content is not in `i18n/articles_{lang}.json`, which `build_sitemap` uses to decide what exists. The HTML pages and their hreflang are fine. This is non-English, so it has little effect on English search.

**Risk:** none.

### 8. Internal link hygiene — Low

- **7 English recipes link with an absolute `http://` URL and no trailing slash**, e.g. `pot-brownies` → `http://www.howtoedibles.com/recipes/cannabutter`. Each costs two 301 hops. `weed-infused-popcorn` links to `/recipes/butter`, which is a 404 (see #2). These come from the legacy recipe HTML in `data/recipes.json`. Make them relative with the trailing slash.
- **102 broken links in translated articles** to `/pt/pt/articles.html`, `/de/de/…` and so on, from a double language prefix. Non-English.
- **Translated 404 and article pages** have 0 or 2 `<h1>` elements (33 pages, es/zh/de/pt only). Cosmetic.

**Risk:** none.

### 9. hreflang — Low (mostly correct)

**Correct** ([Localized versions](https://developers.google.com/search/docs/specialty/international/localized-versions)):
- All recipe, homepage, calculator, donate and article clusters list themselves.
- They are reciprocal and include `x-default` pointing at the English URL.
- They use valid codes (`en`, `pt-BR`, `es`, `de`, `zh-Hans`; Google lists `zh-Hans` explicitly).
- Every target resolves.
- Translated recipes are genuinely translated: 0 of 237 fall back to English ingredients or instructions in any language. So Google's rule that versions are duplicates only "if the main content… remains untranslated" does not apply.

**Defect:** English `/articles.html` has no hreflang block. `build_site.rb` only injects one into index, calculator, donate, 404 and translated articles. So the 4 translated `articles.html` pages point to an English page that doesn't point back, and Google ignores those pairs ("If two pages don't both point to each other, the tags will be ignored").

**Note:** hreflang is declared in both the HTML and the sitemap. Google says this has "no benefit" and only makes maintenance harder. It is fine while the two agree.

**Risk:** none.

### 10. BreadcrumbList level 2 is a search URL — Low

- Recipe breadcrumbs go Home → `https://www.howtoedibles.com/?search=Essentials` → recipe.
- That URL is the homepage filtered by JavaScript, and its canonical is `/`.
- Google defines `item` as "The URL to the webpage that represents the breadcrumb" ([Breadcrumb](https://developers.google.com/search/docs/appearance/structured-data/breadcrumb)). A JS-filtered homepage is a weak fit, but it is valid markup and not an error.

**Fix:** real category pages are a growth lever (see "Not yet specified" in #39). Until then, leave it, or drop level 2.

**Risk:** low.

### 11. Non-site files served publicly — Low SEO, real security note

**Evidence:** GitHub Pages with `.nojekyll` serves the whole branch. Live 200s:
- `/old_rails/README.md`
- `/old_rails/public/404.html` (an indexable HTML page)
- `/old_rails/config/database.yml`
- `/scripts/build_site.rb`
- `/CLAUDE.md`
- `/gen_data.py`

**SEO:** wasted crawl and a stray indexable Rails 404 page. Small. Fix with `Disallow: /old_rails/` and `Disallow: /scripts/` in `robots.txt`, or move them off `master`. Do **not** disallow `/js/`, `/css/`, `/images/` or `/data/`: Google needs JS/CSS to render, and `search-index.json` is fetched by the page.

**Security (outside SEO scope, flagged for the owner):** `old_rails/config/database.yml` and `secrets.yml` contain hardcoded credentials and secret keys. They are publicly downloadable from the site, and the repo is public. Rotate them if they are still used anywhere.

**Risk:** none for the robots lines, as long as the paths listed are only those.

### 12. Homepage and calculator compete for "Edible Dosage Calculator" — Unknown

- The homepage `<title>` is "Edible Dosage Calculator | Cannabutter & Cannabis Recipes".
- `calculator.html` is "Edible Dosage Calculator — Calculate THC mg Per Serving | HowToEdibles".
- The old `/edible-dosage-calculator` URL consolidates into `calculator.html`.

Two pages targeting the same head term can split signals. But the homepage may be what ranks today.

**Do not change either title without GSC Performance data** (query "edible dosage calculator" → which page gets the clicks). **Risk: high** if done blind; the safe path is to change one page and measure for 4+ weeks.

The same rule covers the 95 English pages with titles over 65 characters (56 recipes): truncation is cosmetic, and rewriting titles on ranking pages carries risk for little gain. Leave them.

### Info: FAQPage markup

FAQPage JSON-LD is present on 1,386 pages (all recipes, calculator, articles; 288 in English). Since August 2023, FAQ rich results are "only… shown for well-known, authoritative government and health websites". Google also says "there's no need to proactively remove it" and unused markup "does not cause problems for Search" ([HowTo/FAQ changes](https://developers.google.com/search/blog/2023/08/howto-faq-changes)). No action. (The FAQ text is visible on the pages, and it also helps AI-assistant extraction.)

Content observation for the content-keep ticket, not a technical defect: the 237 English recipes share only 102 distinct FAQ sets, with up to 12 recipes using an identical set. That is boilerplate.

### Performance notes (no ranked defect)

- **Render-blocking CSS:** Bootstrap 4.5.2 CSS from `stackpath.bootstrapcdn.com` (24 KB gzipped, a separate origin, still returns 200) and `/css/styles.css` (13 KB gzipped).
- **Font Awesome 6** loads non-blocking via `preload` + `onload`.
- **Scripts:** jQuery-slim and the Bootstrap bundle sit at the end of `<body>`; AdSense and GA4 are `async`.
- **Images:** tiny (#3 is about quality, not weight); cards and hero have fixed CSS heights.
- **Main CWV risk:** ads (#4).
- **Optional:** self-hosting Bootstrap removes a third-party origin and the dependence on a legacy CDN host. Small, safe win; low priority.

## Suggested order (all safe under the #39 constraint)

1. Discard the `edible-dosage-calculator` deletion (#1). Today, zero effort.
2. Add the missing images `pot-brownies.jpg` and `infused-condensed-milk.jpg` (#5).
3. Pull GSC data: Not found (404), Links, Core Web Vitals (mobile), Recipe rich results, and queries for "edible dosage calculator". This decides how far to take #2, #4 and #12.
4. Add meta-refresh stubs for legacy URLs with value, one-to-one only (#2).
5. Reserve ad space with CSS (#4).
6. `build_site.rb` data fixes (#6, #7, #9, #8) in one regenerate-and-diff pass. Review the diff for unintended title/text changes before merging.
7. Replace placeholder recipe photos, legacy and high-impression recipes first (#3). The largest effort and the largest upside.
8. `robots.txt` hygiene and credential rotation (#11).
