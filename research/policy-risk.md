# How exposed is howtoedibles.com to Google quality and spam policies?

Research for ticket #43 (map #39). Snapshot of `master` @ `359e8a11` (2026-06-25), researched 2026-11-08.
Planning only: nothing on the site was changed.

## TL;DR

- **Nearly all the content went up in one 3-week AI batch.** Before 2026-03-04 the site had **41 recipes and 2 articles**. Between **2026-03-04 and 2026-03-25** it added **196 recipes, 49 articles and about 1,150 translated pages**. Commits were authored by Claude sessions (`Co-Authored-By: Claude Sonnet 4.6 / Opus 4.6`, `claude.ai/code/session_…`). Google's March 2026 spam update rolled out on 2026-03-24 and the March 2026 core update ran from 2026-03-27 to 2026-04-08, both right after the batch.
- **The recipe batch has the scaled-content fingerprints raters are told to look for.** 196 of 196 new recipes use a generated placeholder image (category icon plus the title). 55–70% of each page's main-content words sit in lines copied verbatim onto 3 or more other pages. A template bug prints "This cannabis **cannabis** nachos recipe…" on 146 English pages. In 61 of the 100 recipes added on 2026-03-15, the dosing line contradicts the calculator.
- **The health articles are clear YMYL but carry no E-E-A-T signals.** None of the 50 articles has a named author or reviewer, the site has no about page, and no article links the studies it cites. Even so, they give medical dosing (THC/CBD for PTSD, chronic pain, pets) and drug doses in pregnancy. At least one claim contradicts its own primary source (the MAPS PTSD trial).
- **Translations are 79% of the sitemap and the least valuable part of the site.** All 948 translated recipe pages contain the 4 recipe-specific sentences left in English. 51 "translated" article URLs (`/de/`, `/es/`, `/pt/`, `/zh/`) are actually the English body verbatim with a self-canonical, so they duplicate English pages.
- **No GSC data was used here.** "Exposed" means the content matches the policy descriptions. It does not mean a penalty happened. Whether one did is for the GSC checks listed at the end.

## Risk table

| Content group | Pages (EN) | Risk | Main evidence |
|---|---|---|---|
| Rails-era recipes (pre-2026, URLs unchanged) | 41 | **Low–Medium** | Human-written originals, 33/41 real photos. Retrofitted with templated sections on 2026-03-14 (59% shared lines). 8 photos replaced by placeholders, 7 of them recoverable from git. |
| 2026-03-04/05 recipes (Vegan/Keto/Mocktail/Dessert/Lunch + Brazilian) | 96 | **High** | 96/96 placeholder images, 62–70% shared template lines, 48/96 "cannabis cannabis". |
| 2026-03-15 batch recipes | 100 | **High (highest)** | 100/100 placeholders, 94/100 doubled word, 61/100 dosing line contradicts calculator, template advice contradicts the recipe's own steps. |
| Legacy articles (calculator explainer, bad-trip) | 2 | **Low** | Pre-2026, unique and useful, on-niche. |
| Edibles how-to / cooking / culture articles | ~22 | **Medium** | On-niche and generally sound. Part of a 48-article AI batch in 3 weeks, no author, no sources. |
| Health / medical YMYL articles | ~15 | **High** | Dosing regimens for PTSD, chronic pain, pets and pregnancy alternatives. No author, reviewer or citations. Factual spin found. |
| Legal / drug-testing / travel articles | ~5 | **Medium** | YMYL (legal, employment). The drug-testing sample is accurate and harm-reducing. The legal guide is vague and undated. |
| Off-niche (cannabis stocks, industry future, legalization & crime) | ~4 | **Medium–High** | YMYL-finance and topical drift with no expertise. Mainly a "many topics" signal. |
| Translations, recipes (pt/es/de/zh) | 948 | **High** (site-wide weight) | English sentences on every page, doubled-word bug carried into the translations ("大麻大麻布朗尼"), term-mapping translation artifacts. |
| Translations, articles mostly English (self-canonical) | 51 | **High** | Exact duplicates of English articles under `lang="de"` and similar. They can compete with or dilute the English URL. |
| Translations, articles actually translated | ~161 | **Medium** | Unreviewed machine translation of unreviewed AI content, done in one day (2026-03-21). |

## What the policies say (primary sources)

**Scaled content abuse (spam policy).** Google defines it as "many pages are generated for the primary purpose of manipulating search rankings and not helping users… no matter how it's created." Examples include "Using generative AI tools or other similar tools to generate many pages without adding value for users". Another example covers scraping "including through automated transformations like synonymizing, translating". The stated remedy is "If you're hosting such content on your site, exclude it from Search." [Spam policies](https://developers.google.com/search/docs/essentials/spam-policies)

**Policy rationale.** The policy applies "whether content is produced through automation, human efforts, or some combination". Violators "may rank lower in results or not appear in results at all". Ranking is "primarily designed to work on the page level", but "We do have some site-wide signals". [March 2024 core update and spam policies post](https://developers.google.com/search/blog/2024/03/core-update-spam-policies). The [ranking systems guide](https://developers.google.com/search/docs/appearance/ranking-systems-guide) says the helpful content system "became part of our core ranking systems" in March 2024, and that "Site-wide signals and classifiers are also used."

**Gen-AI guidance.** Google says to "manually factcheck and review all AI-generated content for accuracy", and that this review "also applies to metadata like… structured data and image alt text". [Using gen-AI content](https://developers.google.com/search/docs/fundamentals/using-gen-ai-content)

**Helpful content self-assessment.** Its search-engine-first warning signs include "Are you using extensive automation to produce content on many topics?" and lots of content on many topics "in hopes that some of it might perform well". Its expertise questions include "written or reviewed by an expert…?" and "easily-verified factual errors?" Under Who/How/Why it asks: "Is it self-evident to your visitors who authored your content?" and whether AI use is "self-evident to visitors through disclosures". Google weighs E-E-A-T more heavily for YMYL, meaning topics affecting "health, financial stability, or safety". [Creating helpful content](https://developers.google.com/search/docs/fundamentals/creating-helpful-content)

**Search Quality Rater Guidelines (2025-09-11 edition).** The [QRG PDF](https://static.googleusercontent.com/media/guidelines.raterhub.com/en//searchqualityevaluatorguidelines.pdf) makes four relevant points:

- §4.6.5 Scaled Content Abuse: "Creating an abundance of content with little effort or originality with no editing or manual curation is often the defining attribute of spammy websites." Raters should rate it Lowest "when you strongly suspect scaled content abuse after looking at several pages on the website."
- §2.3: YMYL Health or Safety covers "Topics that could harm mental, physical, and emotional health".
- §4.5.2: "If a page on YMYL topics is highly inexpert, it should be considered Untrustworthy and rated Lowest."
- §4.5: "Multiple or significant factual inaccuracies" make a page untrustworthy.

Rater scores don't directly change rankings, but they describe what the systems are tuned toward.

**Recipe structured data.** The image must be the "Image of the completed dish" and "Images must represent the marked up content". [Recipe docs](https://developers.google.com/search/docs/appearance/structured-data/recipe). A structured-data manual action removes rich-result eligibility but "doesn't affect how the page ranks". [SD policies](https://developers.google.com/search/docs/appearance/structured-data/sd-policies). FAQ rich results are shown "only… for well-known, authoritative government and health websites", and unused markup "does not cause problems". [2023 FAQ change](https://developers.google.com/search/blog/2023/08/howto-faq-changes)

**Multilingual sites.** Google warns against "Translating only the boilerplate text… while keeping the bulk of your content in a single language" and recommends "a single language for content and navigation on each page". [Multi-regional sites](https://developers.google.com/search/docs/specialty/international/managing-multi-regional-sites)

**Manual actions.** Scaled content abuse surfaces under "Major spam problems" and "Thin content with little or no added value". There is also a "Structured data issue" action. [Manual actions report](https://support.google.com/webmasters/answer/9044175)

### Google ranking updates 2025–2026

From the [Search Status Dashboard](https://status.search.google.com/products/rGHU1u87FJnkP6W2GwMi/history):

| Update | Start | Relevance to this site |
|---|---|---|
| March 2025 core | 2025-03-13 | Before the batch (baseline) |
| June 2025 core | 2025-06-30 | Baseline |
| August 2025 spam | 2025-08-26 (26 days) | Baseline |
| December 2025 core | 2025-12-11 | Baseline |
| February 2026 Discover | 2026-02-05 | Discover only |
| **March 2026 spam** | **2026-03-24 → 03-25** | "applies globally and to all languages". Released 3 days after the 2026-03-21 article/translation drop. |
| **March 2026 core** | **2026-03-27 → 04-08** | First core update after the whole batch |
| May 2026 core | 2026-05-21 | Second look at the batch |
| June 2026 spam | 2026-06-24 | Released the day before the 2026-06-25 SEO commits |
| August 2026 spam | 2026-08-18 | |
| September 2026 spam | 2026-09-24 → 10-08 | Most recent |

No 2025–2026 Search Central post changed the scaled-content, AI-content or E-E-A-T rules. The 2026 policy posts cover back-button hijacking (April) and site reputation abuse (August), and neither applies here ([blog index](https://developers.google.com/search/blog)). The rules themselves haven't moved. What changed in 2026 is that four spam updates and two core updates have each re-evaluated the site since the batch.

## Evidence by content group

### How the cohorts were identified

From git history:

| Cohort | Commit(s) | Count |
|---|---|---|
| A. Rails-era recipes (ported 2026-03-04, same `/recipes/{slug}/` URLs as the Rails `get '/recipes/:recipe_slug/'` route) | `92290b4f` | 41 |
| B. "Add 85 new recipes…" | `945b9e65` 2026-03-04 | 85 |
| C. Brazilian + condensed milk | `0fc774c8`, `31793ea4` 2026-03-05 | 11 |
| D. "Add 100 new cannabis recipes" | `ae355e0b` 2026-03-15 | 100 |
| Articles | `b1073bbb` (6) and `902768e5` (20) 2026-03-05, `d7a95dd2` (1) 03-13, `948020df` (20) 03-21, `dd657d83` (1) 03-25. Only 2 predate 2026 (`92290b4f`, ported from Rails `public_pages`). | 48 new + 2 legacy |
| Translations | `b3fa0905`, `8bd6f277`, `0a377233` (03-05..03-09), `948020df` + `8e8d20f7` (03-21: 13 + 67 article pages) | ~1,150 pages |

### Recipes, measured on all 237 English pages

Main content was taken from the recipe header up to the calculator. A line counts as "shared" when it appears verbatim on 3 or more recipe pages. A placeholder is an image with fewer than 400 distinct colours at 80×50: real photos measured about 2,000–4,000 and placeholders about 200–300, with every case spot-checked visually.

| Cohort | n | Placeholder image | Avg main-content words | % words in shared lines | "cannabis cannabis" bug | Dose line says "N grams of cannabutter/infused oil" |
|---|---|---|---|---|---|---|
| A Rails-era | 41 | 8 | 796 | 59% | 4 | 0 |
| B 2026-03-04 | 85 | **85** | 689 | **70%** | 43 | 0 |
| C 2026-03-05 | 11 | **11** (1 file missing: `infused-condensed-milk.jpg`) | 763 | 62% | 5 | 0 |
| D 2026-03-15 | 100 | **100** | 836 | 55% | **94** | **61** |

What the numbers mean:

- **Templating.** `ffef9054` (2026-03-14) added 5 sections (dosing tips, mistakes, storage, variations, 5-question FAQ) to every recipe. The sections come from ~47 `sub_category` templates in `i18n/recipe_sections_en.json`, plus only 4 recipe-specific sentences per recipe (`*_unique` in `data/recipe_enrichment.json`). For example, all 26 `baked_goods` pages carry the same FAQ ("Can I adjust the dosage after baking?") and the same tips. The template intro `"This cannabis %{name} recipe"` doubles the word whenever the name already starts with "Cannabis". That accounts for 146 English pages (142 of them in the new cohorts), and the bug was carried through translation into the other languages.
- **Templates contradict the recipe.** On `cannabis-vegan-mushroom-stroganoff`, the steps sauté onions in cannabis coconut oil. The template's "Common Mistakes" says searing in cannabis oil "destroys THC", and its dosing tip says "add a measured tablespoon of cannabis oil to each serving". The FAQ answers questions about veggie burgers and "vegan steak dinner", which the page doesn't cover. This is what "no editing or manual curation" (QRG §4.6.5) looks like on a page.
- **Dosing accuracy (YMYL-relevant).** 61 of the cohort-D recipes print the calculator-bound quantity as "**3.5 grams of cannabutter**" or "grams of cannabis-infused oil", e.g. `cannabis-lasagna`. Meanwhile `window.RECIPE_DEFAULTS = { quantity: 3.5, … potency: 14 }` and the formula `10 × grams × THC%` treat it as 3.5 g of 14% flower. The displayed mg per portion is therefore off by more than an order of magnitude against the ingredient the page tells you to use. For a dosing site this is the most serious accuracy defect found, and it is an "easily-verified factual error" on a safety topic.
- **Placeholder images in Recipe schema.** Every Recipe JSON-LD `image` points at the placeholder, a card with the category icon and the dish name (e.g. `images/recipes/cannabis-vegan-mushroom-stroganoff.jpg`, 800×500). Google requires an "Image of the completed dish". The likely outcome is lost recipe rich-result or image eligibility, or a structured-data manual action. Neither affects web ranking directly, per the SD policies. On a recipe SERP, a page without a dish photo is also visibly lower-effort.
- **Rails-era regression.** `1718a872` ("use placeholder image for 10 new recipes") replaced real photos with placeholders on 10 old recipes, and only 3 were restored later. The real files for `cannabis-avocado-toast`, `cannabis-hot-chocolate`, `cannabis-salad-dressing`, `infused-ghee`, `infused-granola`, `infused-hummus` and `weed-rice-krispie-treats` still exist at `git show 1718a872~1:static-site/images/recipes/<slug>.jpg`. `pot-brownies` has had a placeholder since the static port.
- **Volume and shape.** 196 recipes in 12 days, each with a schema `datePublished` of 2026-03-04/15, the same 7-section structure, the same FAQ format, and a placeholder image. The QRG tells raters to judge "after looking at several pages on the website", and this is exactly the pattern that check finds.

### Articles (50 English)

Measured on every root article page:

- **Author.** All use `"author":{"@type":"Organization","name":"HowToEdibles"}`. There is no person, reviewer, credentials or about page; the site has `contact.html` and `donate.html` but no about page.
- **Sources.** No article hyperlinks the studies it cites. The only outbound links site-wide are `beyondchronic.com` on the calculator explainer and a `bit.ly` chat link on the bad-trip page. Studies are named in prose only (e.g. "A 2016 meta-analysis published in BMJ Open").
- **Disclaimers.** A medical-style disclaimer appears on only 6 (alcohol, gut health, immune, pets, sleep, seniors). The stocks article has a financial disclaimer. The footer says "For educational purposes only".
- **Volume.** 48 articles in 21 days across health, legal, finance, culture and cooking. That matches "extensive automation to produce content on many topics" and "many different topics in hopes that some of it might perform well".

YMYL samples:

| Article | YMYL type | Observations |
|---|---|---|
| `cannabis-and-ptsd` | Mental health | Gives a full regimen: "Start with 10 to 15 mg of CBD… optimal… 25 to 50 mg per day", THC "1 to 2.5 mg", ratios 10:1 → 2:1. It says the MAPS trial had "76 veterans" and that "the active cannabis groups showed greater reductions". The [primary paper](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0246990) has N = 80 and concludes "no active treatment statistically outperformed placebo". That is a verifiable misstatement on a mental-health page. |
| `cannabis-and-pregnancy` | Health | Consensus-aligned (ACOG/AAP/Surgeon General) and the cited studies match real papers. It also gives drug dosing (B6 "10 to 25 mg three times daily", sertraline, ondansetron) with no author or reviewer. Content is mostly OK; the risk comes from the missing E-E-A-T. |
| `cannabis-edibles-for-chronic-pain` | Health | THC "5 and 25 mg… one to three times daily" and CBD "up to 100 mg or more", with no reviewer. |
| `cannabis-and-pets` | Animal health | Per-kg CBD dosing tables for dogs and cats. The cited studies (Cornell 2018, CSU 2019) are real. No vet reviewer. |
| `cannabis-and-drug-testing` | Employment/legal | Accurate and harm-reducing: it explicitly says detox products are unproven. Lower risk. |
| `cannabis-legalization-guide` | Legal | Generic, with no state list or as-of date ("the majority of US states…"). This is low-effort rather than harmful. |
| `cannabis-stocks-beginners-guide` | Finance | Has a disclaimer and is generic. Off-niche for an edibles site. |

Near-duplicate article pairs could cannibalise each other: `how-edibles-can-help-with-pain` / `cannabis-edibles-for-chronic-pain`, `cbd-vs-thc` / `cooking-with-cbd-vs-thc`, `why-use-cannabis-topicals` / `how-to-make-cannabis-topicals`, and `how-a-cannabis-calculator-works` / `why-our-calculator-is-the-most-accurate`.

Displayed dates don't always match publication. `cannabis-and-pregnancy` shows "March 17, 2026" but was committed on 2026-03-21. The sitemap `lastmod` is 2026-03-15 or 2026-06-25 for every URL. Google flags "changing the date of pages to make them seem fresh". This is minor here, but `lastmod` shouldn't be bumped site-wide again without real changes.

### Translations

- **Scale.** `sitemap.xml` has 1,368 URLs. 1,076 of them (79%) are `/pt/ /es/ /de/ /zh/`, 269 each, against 292 English. Including article pages that aren't in the sitemap, the site has ~1,170 translated pages.
- **Mixed-language recipe pages.** All 4 × 237 = 948 translated recipe pages contain the 4 recipe-specific `*_unique` sentences in English. Examples:
  - The zh `pot-brownies` intro is Chinese followed by "Fudgy cannabis brownies are the most iconic edible of all time…".
  - de: "Füge cannabis-infused coconut oil als Finishing-Nieselregen hinzu" ("drizzle" rendered as drizzle-rain, with an untranslated term).
  - `scripts/translate_recipes.rb` is a word-substitution dictionary ("Translates… using term mapping"). Google's multilingual guidance says to use a single language per page.
- **Untranslated article duplicates.** 51 translated article URLs have a body that is ≥50% verbatim English: pt 7, es 13, de 16, zh 15. They are mostly the 2026-03-21 batch, including `de/cannabis-and-ptsd`, `es/cannabis-and-pregnancy` and `zh/cannabis-and-pets`. Each has `<html lang="de">` (or the matching language), an English meta description, a self-referencing canonical, and hreflang pointing back to the English URL. They are not in the sitemap but are linked through hreflang and listings. These are **the translation issue most likely to touch English traffic directly**: they are same-language duplicates of the English pages, so Google may cluster them and could pick the wrong canonical.
- **Value to the English goal.** None, beyond dilution. The map says other languages "matter only insofar as they help or hurt English". On the risk side they make up 79% of the sitemap, so they dominate any site-wide quality estimate.

## Mitigations

These are suggestions only. Execution is out of scope for this map. Every one must respect "no change may harm current traffic", so check GSC page-level clicks per URL group before acting.

### Safe (low or no traffic risk, reversible, improves accuracy)

1. **Fix the 61 dosing lines** in the 2026-03-15 recipes so the calculator quantity reads as grams of flower, as the Rails-era recipes do ("N grams of ground cannabis, made into cannabutter"). Edit the data in `data/recipes.json` / `recipes_text.json`, then rebuild. This is a pure accuracy fix.
2. **Fix the template bug** "cannabis %{name}" in `i18n/recipe_sections_*.json`, e.g. drop "cannabis" when the name already contains it.
3. **Restore the 7 real Rails-era photos** from `1718a872~1`.
4. **Add an About page plus a visible editorial note** saying who runs the site, how recipes and articles are made (AI-assisted, reviewed or not), and what the dosing formula is. This answers Google's Who/How/Why questions, and Google explicitly suggests disclosing AI use. It is additive.
5. **Hyperlink the sources the articles already name** (PMC, PLOS, ACOG, FDA), add a medical disclaimer to every health article, and correct the PTSD/MAPS claim. All additive.
6. **Remove contradictory or irrelevant template lines** per sub-category, at least the ones that contradict a recipe's own method. The FAQ schema can stay ("does not cause problems").

### Needs a staged, reversible, measured rollout

7. **The 51 English-bodied translation URLs.** Either canonical them to the English URL or `noindex` them, after confirming in GSC that they earn ~0 clicks. Both are reversible. Do it in one batch and watch the English twins for 2–4 weeks.
8. **Real photos for the 204 placeholder recipes** (e.g. `scripts/generate_images_gemini.py`). Start with the recipes that already earn impressions, and follow Google's AI-image guidance by keeping images truthful to the dish. Changing an image is low-risk per page, but stage it so any image-search effect can be measured.
9. **Pruning or noindexing low-value recipes and off-niche articles** (stocks, industry future, crime). Only for URLs with ~0 clicks over 12+ months of GSC data (or since publication for March 2026 pages), in batches, with 301s where a URL had any value.
10. **Translation trees.** Options run from noindexing all translated recipe pages, to keeping only fully translated articles, to removing whole languages. This is the biggest site-wide lever but is high-variance. Run it per language (zh first if it earns least), measure English for a full cycle, and include it in the "translations' fate" decision on map #39.
11. **Expert review of the ~15 health articles** (a named, credentialed reviewer). The quality benefit is high and the traffic risk is low, but it costs money. Decide in the E-E-A-T ticket.

### Don't

- Don't bulk-rewrite or bulk-redate pages (Google's "changing the date" warning).
- Don't add more scaled content (new recipe/article batches) until the above is measured.
- Don't fake authors: Google calls AI headshots and invented credentials deceptive.

## Open questions for the GSC/GA4 tickets

1. Does GSC → Security & Manual actions show anything, in particular "Major spam problems", "Thin content" or "Structured data issue"?
2. Compare clicks and impressions for cohorts A/B/C/D, the articles and the translations around **2026-03-24 → 04-08**, **2026-05-21**, **2026-06-24** and **2026-09-24 → 10-08**. Did impressions for new URLs rise and then fall after a core update (a typical scaled-content pattern), or never arrive (not indexed)?
3. Page indexing report: are the new recipes and translations "Crawled – currently not indexed" or "Duplicate, Google chose different canonical"? That would be especially telling for the 51 English-bodied translation URLs.
4. Which URLs earn the current flat traffic? If it is mostly the 41 Rails-era recipes and the 2 legacy pages, the March 2026 content is risk without reward, and pruning or noindexing it is low-risk.

## Method notes

These were one-off scripts and are not committed:

- The recipe analysis parsed `recipes/*/index.html` from `recipe-header` up to "Calculate Your Dose".
- Cohorts came from `git ls-tree 92290b4f` and `git show --diff-filter=A` on the commits above.
- The image test used PIL distinct-colour counts.
- Article flags were regexes over each root `*.html` (JSON-LD author, outbound links, disclaimer phrases).
- The untranslated-article check compared each `/{lang}/X.html` against `/X.html`, using lines over 80 characters.
- The QRG pages were read from the 2025-09-11 PDF (pp. 11–12, 35–36, 42–43).
