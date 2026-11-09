# AI-assistant citations: what earns them, and how howtoedibles.com measures up

Research ticket #42 (map #39). Researched 2026-11-08. Planning only: nothing on the site was changed.

**Confidence labels.** **[P]** = primary vendor doc, fetched 2026-11-08. **[A]** = academic or independent measurement. **[L]** = SEO blog, third-party report or my own inference. Treat [L] as unverified.

## TL;DR

1. **Being crawlable and indexed by the *search* bots is the whole entry ticket.** Each vendor uses separate user-agents for training and for search/retrieval, and only the search/retrieval ones decide whether you can be cited. Google says AI Overviews and AI Mode need nothing beyond normal Search eligibility: no special files, no special schema. [P]
2. **howtoedibles.com already passes the access test.** robots.txt allows everything. GitHub Pages serves bot user-agents with HTTP 200, and no CDN bot-blocking is in front.
3. **llms.txt has no measured or officially acknowledged effect on citations.** Google explicitly says no "AI text files" are needed. Keep the existing file (it's free), but don't invest in it. [P]
4. **What gets quoted:** facts in visible static HTML, clear headings, tables, specific numbers, cited sources, freshness, and structured data that matches the visible text. [P] (Google, Bing) and [A] (GEO paper).
5. **Biggest content gap: recipe pages show no per-serving THC number without JavaScript.** The dosage card renders "—" in the HTML. Retrieval bots generally don't run JS [L], so the site's core differentiator, "mg per serving", is invisible to them on 237 pages.
6. **Cannabis:** no assistant vendor documents a cannabis-specific filter on *citations*. Their usage policies target illegal production or sale and individualized medical dosing. Google AdSense already treats marijuana content as "restricted" (limited ads). That's the current state and no recommendation here changes it.
7. **Measurement:** GA4 now has a built-in **AI Assistant** default channel. Bing Webmaster Tools has an **AI Performance** report with Copilot citation counts and grounding queries. Google AI Overviews and AI Mode clicks are folded into GSC "Web" / GA4 Organic Search and cannot be separated. [P]

---

## 1. Crawlers: training vs search/retrieval

| Vendor | User-agent | Role | Honors robots.txt | Blocking it means |
|---|---|---|---|---|
| OpenAI | **OAI-SearchBot** | Indexes sites for ChatGPT search | Yes | "Sites that are opted out of OAI-SearchBot will not be shown in ChatGPT search answers" (navigational links may still appear). OpenAI recommends allowing it and its IP ranges. Changes take about 24 h. [P1] |
| OpenAI | GPTBot | Training | Yes | Content not used for training. "Each setting is independent of the others", so blocking it does **not** affect ChatGPT search. [P1] |
| OpenAI | ChatGPT-User | Live fetch when a user or GPT action asks | "robots.txt rules may not apply" | Not used to decide Search inclusion. [P1] |
| OpenAI | OAI-AdsBot | Checks ChatGPT ad landing pages | n/a | Irrelevant here. [P1] |
| Anthropic | **Claude-SearchBot** | Indexes content "to enhance the relevance and accuracy of search responses" | Yes | Lower visibility in Claude search. [P2] |
| Anthropic | **Claude-User** | Live fetch for a user's question | Yes | "prevents our system from retrieving your content in response to a user query." [P2] |
| Anthropic | ClaudeBot | Training | Yes | Excluded from future training sets. Since 2026-10-30 Anthropic also honors an IETF aipref "no AI training" signal; an explicit ClaudeBot rule overrides it. [P2] |
| Perplexity | **PerplexityBot** | Search index ("surface and link websites") | Yes | Not used for training. Perplexity recommends allowing it. [P3] |
| Perplexity | Perplexity-User | Live fetch for a user | "generally ignores robots.txt" | Not used for training. [P3] |
| Google | **Googlebot** | Search, *including* AI Overviews and AI Mode | Yes | AI features are controlled only through Googlebot plus `nosnippet` / `data-nosnippet` / `max-snippet` / `noindex`. [P4] |
| Google | Google-Extended | A control token, not a crawler. Covers Gemini training **and grounding** in Gemini Apps and Vertex AI | Yes | "does not impact a site's inclusion in Google Search nor is it used as a ranking signal". **Blocking it would cut Gemini-app grounding citations.** AIPREF support is planned for early 2027. [P5] |
| Microsoft | **Bingbot** | Bing index, which feeds Copilot and Bing AI summaries | Yes | Default (no tag) means full inclusion in AI answers. `NOCACHE` limits answers to link, title and snippet. `NOARCHIVE` alone excludes the page from AI answers. Neither tag affects classic Bing results. [P6] |

Notes:
- Claude's web search is reported to use a third-party index (Brave) as well as Claude-SearchBot. [L] If true, Brave indexing also matters, and nothing on our side blocks it.
- ChatGPT search has historically drawn partly on Bing results. [L] Bing hygiene is therefore worth having for both Copilot and ChatGPT.

## 2. llms.txt

- Proposed by Jeremy Howard in September 2024. v2 was revised in August 2026. The stated use is inference-time ("used on demand, when an agent needs information"), not crawling or training. [P7]
- The spec does **not** claim that any search engine or assistant reads other sites' llms.txt for ranking or citation. Its adoption evidence is that AI labs *publish* llms.txt for their own docs, CMS platforms auto-generate it, and Chrome Lighthouse checks for it under "agentic browsing" (that last claim I did not verify). [P7]
- Google: "You don't need to create new machine readable files, AI text files, or markup to appear in these features." [P4]
- OpenAI, Anthropic, Perplexity and Microsoft bot docs don't mention llms.txt as an input. [P1–P3, P6]
- **Verdict:** no measured effect. Keep `/llms.txt` (it's harmless and maybe useful to agents), but don't spend effort on it.

## 3. Content shapes that get cited

Primary-source guidance:
- **Google** [P4]: put important content in text form; use internal links; give a good page experience; keep structured data consistent with the visible page. "There's also no special schema.org structured data that you need to add."
- **Bing AI Performance** [P8] says what cited pages tend to have:
  - "Clear headings, tables, and FAQ sections help surface key information."
  - "Examples, data, and cited sources help build trust."
  - "Regular updates…"
  - Consistency across text, images and video.
  - IndexNow for change notification.
- **Bing sitemaps** [P9]: lastmod is "a key signal", so make it accurate. Don't set it to the sitemap generation time unless the content actually changed. changefreq and priority are ignored.
- **Google FAQ rich results were removed from Search on 2026-05-07** [P10]. FAQPage markup no longer produces a Google rich result. It's harmless, and other engines may still parse it, but it's no longer a reason to add FAQs.
- **Recipe schema** [P11]: requires `name` and `image`. `recipeIngredient` should be just the ingredient text. Times are ISO 8601. There is no cannabis-specific note.

Independent evidence:
- GEO paper (Aggarwal et al., KDD 2024, arXiv 2311.09735) [A]: adding **statistics, quotations and cited sources** raised source visibility in generative-engine answers by up to about 40%. Keyword stuffing did not help. It was measured on simulated engines, so the direction is useful but the magnitude may not transfer.
- AI crawlers (GPTBot, ClaudeBot and others) largely **don't execute JavaScript**; Googlebot does (Vercel/MERJ crawler study, Dec 2024). [L] I couldn't confirm this from OpenAI or Anthropic docs, so the safe assumption is that **anything JS-only is invisible to non-Google AI**.

What this means here: put the specific answer (number, range, formula) in the first sentences under a question-style heading, in static HTML. Add a table where data is tabular. Cite primary studies. Keep facts consistent across pages and schema.

## 4. Is cannabis content filtered?

- **Citations and answers:** none of the crawler or search docs [P1–P6, P8] mention topic-based exclusion of cannabis sites from citations. Usage policies target *illegal production or sale* of controlled substances and *individualized medical dosing*. Anthropic's AUP lists "Illegally produce, acquire, sell, or distribute controlled or regulated substances" and treats dose recommendations as high-risk medical use. [P12] OpenAI's Model Spec favors "easy access to trustworthy safety-critical information". [P13] I could not retrieve its drug-specific section, so this is unverified.
  - Inference [L]: harm-reduction and dosing-education content ("start at 2.5–5 mg", onset times) is the kind assistants answer and cite. Content framed around illegal sourcing would be the risky kind. In practice, YMYL-style health queries tend to favor sources showing expertise and citations. Google has not documented a cannabis rule for AI Overviews.
  - **No vendor publishes this; verify empirically** (see section 5, manual panel).
- **Ads:** Google Publisher Restrictions list "marijuana" under recreational drugs, including content that "provides instructions on producing… or using recreational drugs". It is **restricted, not prohibited**: fewer bidders, and no Google Ads demand. [P14] This already applies to the site today. Nothing in this research changes it, and AdSense optimization is out of scope for map #39.
- **ChatGPT ads:** OAI-AdsBot checks ad landing pages for safety [P1]. That only matters if the site ever *buys* ChatGPT ads, which is out of scope.

## 5. Measuring AI referral traffic

| Tool | What it shows | Source |
|---|---|---|
| GA4 **AI Assistant** default channel | Sessions where medium = `ai-assistant`. GA4 sets this automatically when the referrer matches its AI-assistant list (examples given: ChatGPT, Gemini, DeepSeek, Copilot, Grok). Perplexity and Claude aren't named, so check whether they land in Referral. AI Overviews and AI Mode stay in **Organic Search**. | [P15] |
| GA4 custom channel group (fallback) | If Perplexity or Claude show up as Referral, add a rule: source matches regex `perplexity\|claude\.ai\|chatgpt\.com\|copilot\|gemini`. ChatGPT links usually carry `utm_source=chatgpt.com` [L]. Note: GA4 data only starts 2026-06-25. | [P15], [L] |
| GSC Performance | AI Overviews and AI Mode clicks and impressions are included in "Web" and **not separable**. | [P4] |
| **Bing Webmaster Tools → AI Performance** | Copilot and Bing AI citation counts, cited URLs, grounding queries, trend. This is the only first-party *citation* report available. A Topics Portfolio beta was added in October 2026. | [P8] |
| Manual prompt panel | About 20 target questions, e.g. "how many mg THC per serving homemade brownies", "edible dosage calculator", "how long do edibles take to kick in". Ask them monthly in ChatGPT, Perplexity, Claude and Copilot, and log whether howtoedibles.com is cited. It's the only way to measure ChatGPT, Perplexity and Claude citations. | [L] |
| Server logs | Not available on GitHub Pages, so bot crawl activity can't be seen directly. | — |

---

## 6. Gap list vs the current site

Checked on master `359e8a11` and the live site on 2026-11-08. Samples: `/robots.txt`, `/llms.txt`, `/recipes/cannabutter/`, `/how-long-do-edibles-take-to-kick-in.html`, `/calculator.html`. **Risk** = risk to current traffic.

### Access (no action needed)

| # | Item | Finding | Recommendation | Risk |
|---|---|---|---|---|
| A1 | robots.txt | `User-agent: * Allow: /` plus sitemap. Every search, retrieval and training bot is allowed. | **Leave as is.** Adding named UA groups gains nothing. A named group *replaces* the `*` group for that bot, so a typo could block it. | Editing it is the risk. |
| A2 | Training opt-out (GPTBot, ClaudeBot, Google-Extended) | Not blocked. | Leave as is. GPTBot and ClaudeBot opt-outs are safe for search, but **Google-Extended also controls Gemini grounding**, so blocking it would cut Gemini citations. | High if Google-Extended is blocked. |
| A3 | Hosting | GitHub Pages / Fastly. GPTBot, ClaudeBot and OAI-SearchBot user-agents get 200. No bot-blocking CDN. | Keep. If you ever move behind Cloudflare, check its AI-bot blocking default, which is reportedly on for new zones. [L] | — |
| A4 | llms.txt | Present and accurate (formula, safety numbers, key pages). | Keep it and update the counts when recipes change. Do no more. | None |

### Measurement (cheapest, highest value; zero site risk)

| # | Item | Finding | Recommendation | Risk |
|---|---|---|---|---|
| M1 | Bing Webmaster Tools | No `msvalidate.01` meta tag or `BingSiteAuth.xml` in the repo. It could still be verified by DNS or GSC import; unknown. | Verify in BWT (GSC import needs no site change), submit the sitemap, and read **AI Performance**. | None |
| M2 | GA4 AI Assistant channel | Not checked (no GA4 access from here). | Read the channel. Add the custom group if Perplexity or Claude show up as Referral. | None |
| M3 | Manual citation panel | None exists. | Set up the 20-query monthly log. | None |
| M4 | Sitemap lastmod | 183 of 1368 URLs share `2026-06-25`. That could be a real edit date or the build date. | Confirm `build_site.rb` writes real content-change dates (Bing: don't use the generation time). | Low |

### Recipe pages (generated, so the fix belongs in `scripts/build_site.rb`, which covers all 237)

| # | Item | Finding | Recommendation | Risk |
|---|---|---|---|---|
| R1 | **Per-serving THC is JS-only** | `#potency-result` and `#potency-result-total` render `&mdash;`. `window.RECIPE_DEFAULTS = {quantity: 7, portion: 48, potency: 14}` is only read by `calculator.js`. The static HTML has **0** "N mg" strings. | Pre-render the default result into the HTML, and add one sentence like "With the default 7 g of 14% flower in 48 servings, each serving has about 20.4 mg THC (980 mg total). Beginners should aim for 2.5–5 mg." JS still overwrites it. | Low technically. Content risk: a high default (20 mg) could be quoted as "a serving is 20 mg", so always pair it with the beginner range. Stage it on about 20 recipes first and compare GSC. |
| R2 | Ingredient unit missing | Visible HTML and `recipeIngredient` both read "7 ground weed", with no "g". | Emit "7 g ground cannabis (decarboxylated)". | Low |
| R3 | Schema vs text mismatch | `cookTime: PT45M`, but the steps say "simmer for 2-3 hours". Google says to keep structured data consistent with the visible page. | Fix the times in the data. | Low |
| R4 | Contradictory facts | Storage tips say both "up to 2 weeks" and "up to 2 months" refrigerated. Dosing tips mention 60–80% extraction efficiency, while the calculator assumes 100%. | Deduplicate and reconcile the *wording*, e.g. "the calculator shows the maximum; real extraction is lower". **Don't change the calculator math**: users rely on its numbers. | Low (wording); high (math) |
| R5 | Templated FAQ | The same FAQ appears on 5 Essentials recipes (e.g. a slow-cooker *oil* question on the cannabutter page). | Make FAQs recipe-specific, or drop them. Google FAQ rich results are gone, so their main value now is answer text. Overlaps the scaled-content concern on map #39. | Low–medium. Removing visible text from ranking pages: stage it. |
| R6 | Decarb link goes off-site | "Learn how" points to YouTube instead of `/science-of-decarboxylation.html`. | Link internally and keep the video as a secondary link. | Low |
| R7 | Nav mega-menu | About 200 recipe links come before `<h1>` in the raw HTML. | Low priority. Assistants extract the main content reasonably well. Revisit only with evidence. | Medium if restructured, since it affects internal linking sitewide. |

### Articles (hand-maintained English root)

| # | Item | Finding | Recommendation | Risk |
|---|---|---|---|---|
| T1 | Answer not first | The title asks "How long do edibles take to kick in?", but the first paragraph is preamble. The answer (30 min–2 h, peak 2–4 h, lasts 4–8 h) appears only in an H2 and the FAQ JSON-LD. | Add a 1–2 sentence direct answer at the top. Add, don't rewrite. | Low |
| T2 | No tables | The kick-in timeline is in bold-led paragraphs. Key articles have 0 `<table>`. | Add a small summary table (time window → what happens) alongside the existing text. | Low |
| T3 | **No cited sources** | None of the 56 root HTML pages link to NIH, PubMed, CDC, FDA or a DOI. | Add 2–5 primary-research citations to the top articles. This is the strongest signal in both Bing [P8] and the GEO paper [A]. Overlaps E-E-A-T on map #39. | Low |
| T4 | Authorship and dates | `author` is an Organization only. `dateModified` = `datePublished`. A remote `add-about-page` branch exists but is unmerged. | Feed into the E-E-A-T ticket. Update `dateModified` only on real edits. | Low |

### Calculator page (`/calculator.html`, the strongest page)

| # | Item | Finding | Recommendation | Risk |
|---|---|---|---|---|
| C1 | Quotable content | Already has a static dose-tier table (1–2.5, 2.5–5, 5–15, 15–30, 30–50, 50+ mg), the formula, a worked example (3.5 g × 20% / 20 = 35 mg), a FAQ and "Updated March 2026". This is citation-ready. | **Don't restructure.** At most, move the formula and example sentence into the intro paragraph. | Medium if rewritten: this is likely a top-traffic page. |
| C2 | Heading order | The calculator widget's `<h3>`s come before the `<h1>` in the DOM. | Minor; fix only alongside other work. | Low |
| C3 | Extraction caveat | Same as R4: the formula assumes full extraction, while other pages say 60–80%. | Add one caveat line; keep the math. | Low |

### Suggested order (all safe-first)

1. **No site change:** M1, M2, M3, then M4. These produce a baseline before anything is touched.
2. **Additive, low risk:** T1, T2, T3 on the 3–5 top articles from GSC data, then R2, R3, R6.
3. **Staged:** R1 on about 20 recipes, check GSC and AI Performance after 4–6 weeks, then roll out to all. R4 and R5 wording after that.
4. **Leave alone:** A1–A4, C1, R7.

---

## Sources

- [P1] OpenAI, "Overview of OpenAI Crawlers": https://developers.openai.com/api/docs/bots
- [P2] Anthropic Help Center, "Does Anthropic crawl data from the web…": https://support.claude.com/en/articles/8896518
- [P3] Perplexity, "Perplexity Crawlers": https://docs.perplexity.ai/guides/bots
- [P4] Google Search Central, "AI features and your website": https://developers.google.com/search/docs/appearance/ai-features
- [P5] Google, "Google's common crawlers" (Google-Extended): https://developers.google.com/search/docs/crawling-indexing/google-common-crawlers
- [P6] Bing Webmaster Blog, "Announcing new options for webmasters to control usage of their content in Bing Chat" (2023-09-22): https://blogs.bing.com/webmaster/september-2023/Announcing-new-options-for-webmasters-to-control-usage-of-their-content-in-Bing-Chat
- [P7] llms.txt proposal: https://llmstxt.org/
- [P8] Bing Webmaster Blog, "Introducing AI Performance in Bing Webmaster Tools Public Preview" (2026-02-10): https://blogs.bing.com/webmaster/2026/2/Introducing-AI-Performance-in-Bing-Webmaster-Tools-Public-Preview/
- [P9] Bing Webmaster Blog, "Keeping Content Discoverable with Sitemaps in AI Powered Search" (2025-07-31): https://blogs.bing.com/webmaster/2025/7/Keeping-Content-Discoverable-with-Sitemaps-in-AI-Powered-Search/
- [P10] Google, FAQPage structured data (deprecation notes, May/June 2026): https://developers.google.com/search/docs/appearance/structured-data/faqpage
- [P11] Google, Recipe structured data: https://developers.google.com/search/docs/appearance/structured-data/recipe
- [P12] Anthropic Usage Policy: https://www.anthropic.com/legal/aup
- [P13] OpenAI Model Spec (2026-10-29): https://model-spec.openai.com/ (drug-specific section not retrieved)
- [P14] Google Publisher Restrictions: https://support.google.com/adsense/answer/10437795
- [P15] GA4 default channel group: https://support.google.com/analytics/answer/9756891
- [A] Aggarwal et al., "GEO: Generative Engine Optimization", KDD 2024: https://arxiv.org/abs/2311.09735
- [L] Vercel/MERJ, "The rise of the AI crawler" (Dec 2024), on AI crawlers not executing JS. Third-party reports on Claude search using Brave, ChatGPT using Bing, ChatGPT `utm_source=chatgpt.com`, and Cloudflare's AI-bot default. None of these were verified against vendor docs.

Not retrievable: help.openai.com (403) and the Bing Webmaster Guidelines page (JS-rendered).
