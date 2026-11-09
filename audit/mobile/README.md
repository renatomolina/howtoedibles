# Mobile UI audit — 2026-11-08

Asset for the ticket **What's broken in the current mobile UI, and why?** (map: *Wayfinder: gorgeous, simple mobile-first UI redesign*).

**Method.** Live site, headless Chrome with real mobile emulation (viewport meta honoured, touch, iPhone UA, DPR 2) at 360 / 390 / 430 px, light + dark, en / de / zh. Pages: home, a recipe with a real photo (`cannabutter`), a recipe with a placeholder (`pot-brownies`), `calculator.html`, an article (`how-long-do-edibles-take-to-kick-in`). 90 full-page captures in [`shots/`](shots/) (downscaled to 430 px wide, low JPEG quality, to keep the branch small; `crops/` are full resolution), DOM metrics in [`metrics.json`](metrics.json). Ads and analytics were **blocked** for the matrix, because automated impressions on our own AdSense account are invalid traffic. One ads-on pass (en home + pot-brownies, 390 light) is in `shots/*-ads.jpg` / [`metrics-ads.json`](metrics-ads.json). Lighthouse 12 mobile reports are in [`lighthouse/`](lighthouse/). Re-run: `node audit/mobile/audit.mjs [--ads]`, `ruby audit/mobile/lh-run.rb`, `ruby audit/mobile/lh-summary.rb audit/mobile/lighthouse/*.json`.

## Corrections to what was "already spotted"

| Spotted at charting | Verdict | Evidence |
|---|---|---|
| Page wider than the viewport, logo and cards cut off on the right | **Not a site bug: the capture method caused it.** `chrome --headless --window-size=390` with no mobile emulation lays the page out at desktop Chrome's minimum window width (~500 px) and crops the image to 390. With real emulation, `scrollWidth == innerWidth` on all 90 captures and on the ads-on pass. | [`crops/cli-window-390.png`](crops/cli-window-390.png) (reproduced with ads blocked) vs [`shots/en-home-390-light.jpg`](shots/en-home-390-light.jpg) |
| pot-brownies hero shows a placeholder icon although `/images/recipes/pot-brownies.jpg` is in the HTML | **The JPG itself is the placeholder.** It's an 800×500 generated card (icon + title), not a photo. | see the image inventory below |
| Auto ads inject "Discover more" blocks and "Find Support" in-text pills | Confirmed. With ads on, pot-brownies gets **11 ad units** (1 manual + 10 Auto), roughly one every 900 px, and grows from 8.4 to **13.3 screens**. Home grows from 3.7 to 5.7 screens, including an 800 px Auto slot that stays blank above the footer. "Find Support" pills are *ad intents* (see the AdSense research ticket). | [`shots/en-recipe-placeholder-390-light-ads.jpg`](shots/en-recipe-placeholder-390-light-ads.jpg), [`shots/en-home-390-light-ads.jpg`](shots/en-home-390-light-ads.jpg) |
| 19-button pagination wrapping | Confirmed: 21 buttons (19 pages + « »), 36×32 px each, wrapping to 2–3 rows. | `homepage.js` renders every page number |
| 200+ link dropdown menu | Confirmed: **253** nav links on generated pages, **153** on hand-maintained English pages, so the two shells have drifted. | `navLinks` in `metrics.json` |

## Defects and root causes

### Imagery (the biggest visual problem)
- **203 of 236 recipe images are generated placeholders**: 800×500 pastel cards with an icon and the recipe name, which repeats the H1 right below it. 30 are real photos, but only **260×173**: upscaled to a 360×200 hero at DPR 2–3, they look soft. Only 3 are usable-resolution photos (`cannabis-caramel-sauce`, `infused-cold-brew`, `infused-chocolate-bark`, all portrait). `infused-condensed-milk` has no image file at all.
  - The homepage's first 12 cards happen to be the 260 px real photos. Page 2 onward is all placeholders.
  - *Root cause:* content, not CSS. `CLAUDE.md`'s "AI-generated via Gemini" isn't what's on disk. Any premium visual direction has to decide what a recipe looks like **without a photo**, because that's 86% of them.
- Hero `<img>` has no `width`/`height`, a fixed `height: 300px` with `object-fit: cover` (`css/styles.css:1779`), no `srcset`, and sits under the leaderboard ad.

### Layout shift (CLS 0.25 on home: "poor")
- **Homepage grid:** all 227 recipe cards ship visible in the HTML (good for crawling), and `js/homepage.js` hides all but 12 *after* `DOMContentLoaded`. The first paint lays out all 227, then the page collapses. Lighthouse attributes the largest shift to `div.row`.
- **Ad slots reserve 0 px.** The manual `ins.adsbygoogle` (`LEADERBOARD_AD` in `scripts/build_site.rb:454`) has no `min-height`. When it fills it inserts about 390 px **above the hero** on recipe and calculator pages, and above the grid on home. That pushes the recipe H1 from 459 px to about 850 px, below the first screen.
- Homepage card images lack `width`/`height` (hand-maintained `index.html`; generated related-recipe cards do have them).

### Loading (LCP 4.7 s on home)
- The render-blocking chain is Bootstrap 4.5.2 CSS (CDN) → Font Awesome 6.4 `all.min.css` (CDN, whole icon set for a few dozen icons) → `styles.css`, which uses `@import` for Poppins from Google Fonts. The `@import` serialises a third round trip before text can render, and the LCP element is the intro paragraph (text).
- Lighthouse flags 53 KiB unused CSS and 297 KiB unused JS, mostly ads plus **a second gtag still loading `UA-90858722-1`**: a dead Universal Analytics destination still linked in the GA4 Google tag.
- Poppins has no CJK glyphs, so zh renders in a system fallback beside Latin Poppins (mixed typography).

### Touch & legibility
- Calculator: range sliders are **6 px** tall, −/+ steppers **30×30**, number inputs 50×31. All are below the 44 px target, and they're the controls people use most on this site.
- Site search input is **15.2 px** (`.site-search-input { font-size: 0.95rem }`). iOS Safari zooms the page on focus for inputs under 16 px, so the primary job causes a zoom jump.
- Text under 12 px: home card category label 9.6 px; recipe category badge 10.9 px; dose-card labels 11.2 px; dosage-effects titles and side notes 11.5 px. On recipe pages 80 of ~100 visible text elements are under 16 px.
- Footer, TOC and breadcrumb links are 15–18 px tall with no padding: tiny, tightly stacked tap targets.

### Dark mode
- Calculator page dose table: the **"Casual 5–15 mg" row is near-invisible** (dark text on dark), and the other rows keep light pastel backgrounds (`.calc-dosage-table tr.table-* td`, `styles.css:2044`, no dark override). This is the dose guidance table, so it's a safety-relevant readability bug. See [`crops/calc-dark-dose-table.jpg`](crops/calc-dark-dose-table.jpg).
- *Root cause, system-wide:* `styles.css` hard-codes **127 distinct hex colours** and uses `var()` only 9 times. Dark mode is a separate layer of **147 `[data-theme="dark"]` overrides**, so every component without its own override breaks in dark. A token-based palette (custom properties redefined once under `[data-theme=dark]`) removes this whole class of bug.

### Information architecture / page length (at 390 px, ads off)
- Recipe page: 8–9 screens (de 9.3). The H1 is at 459 px (ad + hero first). The calculator widget comes *after* all the tips/mistakes/storage/variations/FAQ text, so the dose is about 6 screens down.
- Calculator page: the **H1 is at ~1,200 px**, below the first screen, because the widget renders first.
- Article: 11–15 screens; de is longest (14.1).
- Homepage: hero → ad → 12 cards → donate CTA → pagination. No category entry points on mobile; categories live only in the 253-link menu.

### Shell duplication (affects the implementation plan and article inheritance)
- Navbar/footer exist twice: generated by `build_navbar` in `scripts/build_site.rb` and copy-pasted into ~57 hand-maintained English root pages. They've already drifted (143 vs 243 dropdown items). Any new shell has to land in both places, or the English root pages must start pulling the shell from the build.

### i18n
- No horizontal overflow from long German strings at 360 px. de pages are about 10% longer; de TOC entries wrap to two lines.
- zh: system CJK fallback mixed with Latin Poppins (see Loading).

## Lighthouse mobile (lab, Moto G emulation, ads on)

| Page | Perf | A11y | Best pr. | SEO | LCP | CLS | TBT |
|---|---|---|---|---|---|---|---|
| en home | 80 | 95 | 75 | 100 | 2.3 s | **0.254** | 20 ms |
| en recipe (cannabutter) | 78 | 84 | 79 | 100 | 2.3 s | **0.343** | 40 ms |
| en recipe (pot-brownies) | 78 | 84 | 79 | 100 | 2.0 s | **0.344** | 50 ms |
| en calculator | 92 | 89 | 61 | 100 | 2.2 s | 0 | 40 ms |
| en article | 84 | 92 | 61 | 100 | 2.2 s | **0.224** | 50 ms |
| de home | 94 | 95 | 57 | 100 | 2.4 s | 0.001 | 30 ms |
| zh recipe (pot-brownies) | 76 | 84 | 79 | 100 | 2.4 s | **0.345** | 40 ms |

- **CLS is the Core Web Vital that fails** ("poor" is > 0.25; "good" is ≤ 0.1). On recipe pages Lighthouse attributes it to `div.recipe-hero-img-wrap` being pushed down by the unreserved leaderboard ad above it. On en home it's `div.row` (the JS pagination collapse) plus the ad host. de home (generated) scores 0.001 against en home (hand-maintained) at 0.254, another sign the two shells differ.
- LCP is about 2.0–2.4 s ("good" ≤ 2.5 s), with little headroom. A first run made in parallel with the screenshot matrix gave 4.7 s on home, so treat lab LCP as noisy.
- INP can't be measured in the lab. TBT is 20–50 ms, so main-thread JS isn't the bottleneck. Field CWV (CrUX) wasn't captured: the keyless PageSpeed API returned 429. The Search Console Core Web Vitals report is the place to confirm with real users.
- Accessibility 84–95: colour contrast fails on the orange category labels/badges (`.card-category`, `.recipe-category-badge`) and dosage-panel `h3`s.
- Unused JS 360–435 KiB per page is almost entirely AdSense + two gtag loads (GA4 plus the dead `UA-90858722-1`).

## What this means for the design tickets

1. **Placeholder-first imagery.** The visual direction must look premium for a recipe *with no photo*, because that's 86% of them. The 30 low-res photos are no better in a hero. Replacing the imagery is a content decision, not a layout one.
2. **Reserve space for everything that loads late** (ads, images, paginated grid). The CLS failures are all "unreserved box above content".
3. **Thumb-sized calculator controls**, since it's the site's signature tool: 44 px+ targets, ≥16 px inputs.
4. **One palette defined as tokens** so dark mode can't drift per component, including the dose table.
5. **The shell is duplicated** across the build script and ~57 hand-maintained English pages. The CSS-stack and implementation-plan decisions have to account for it.
6. No overflow and no i18n breakage today, so there's nothing to "fix" there. Only keep it true.
