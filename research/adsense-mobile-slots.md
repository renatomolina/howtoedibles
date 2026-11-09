# AdSense on mobile: manual slots only

Research for #47 (map #45). Researched 2026-11-08. Sources are Google AdSense Help, Google Publisher Policies, Coalition for Better Ads, web.dev and Google developer docs. Anything marked **inference** is my reading and isn't stated by a source.

Decision already taken: **manual units only, Auto ads off.** That includes in-page, related search and in-text ("Find Support" pills).

## Current state (repo)

- Every recipe page and the homepage carry one responsive unit (`data-ad-slot="4353785890"`, `data-ad-format="auto"`, `data-full-width-responsive="true"`), plus `adsbygoogle.js` in `<head>`. Sample: `recipes/pot-brownies/index.html` around line 373, and `index.html` around line 283.
- The unit sits in `.ad-container`, directly under the search input and above the hero image. **`css/styles.css` reserves no height for it**, so its height starts at 0 and the whole page shifts down when the ad renders. That is the worst case for CLS described below.

---

## 1. Turning off Auto ads and their formats

**Where:** AdSense → **Ads** → click **Edit** next to the site (opens the ad settings preview) → **Ad settings** → **Apply to site** → **Apply now** → **Save**. That flow is documented for turning Auto ads *on*; turning off uses the same toggle. ([Set up Auto ads](https://support.google.com/adsense/answer/9261307))

Toggles in the settings panel ([Auto ads settings](https://support.google.com/adsense/answer/9305577)):

| Control | What to set | Source wording |
|---|---|---|
| **Auto ads** (master) | Off | "Turn this option off if you don't want to show Auto ads on your site." |
| **Intent-driven formats → Ad intents** (links / anchors / chips) | Uncheck all three | "Uncheck this option if you don't want to show ad intent links" (same for anchors and chips) |
| **Overlay formats**: anchor, vignette, side rail | Off | "Turn this option off if you don't want to show anchor ads" (same wording for each) |
| **In-page formats**: banner, Multiplex | Off | "Turn this option off if you don't want to show banner ads" / "...Multiplex ads." |
| **In-page formats → Existing ads** ("optimize existing ad units") | Off | "Turn off the Existing ads option if you don't want Google to optimize your existing ad units" ([9261307](https://support.google.com/adsense/answer/9261307)). This setting lets Google "optimize your existing ad units and your Auto ads together" ([9305577](https://support.google.com/adsense/answer/9305577)). |

**Watch for these.**

- **Related search ("Discover more") no longer exists.** "The Related search for Auto ads format was discontinued on August 6, 2026". It no longer serves and has been removed from the UI ([Related search](https://support.google.com/adsense/answer/12999250)). If you still see "Discover more" style chips, they are **ad intents**, not related search.
- **The "Find Support" pills are ad intent chips:** "buttons showing relevant terms that AdSense generates by scanning the existing text in your page's paragraphs". Clicking one opens a dialog with "ads and Gemini-generated content" ([chips](https://support.google.com/adsense/answer/15111968), [ad intents](https://support.google.com/adsense/answer/13844047)). Ad intents live under Auto ads; setup requires "make sure **Auto ads** is turned on" ([13844047](https://support.google.com/adsense/answer/13844047)).
- **Code-level backstop for ad intents.** Putting `google-anno-skip` on `<body>` stops "ad intent links, anchors, and chips" on that page ([13844047](https://support.google.com/adsense/answer/13844047)). It costs one class in the `build_site.rb` layout and doesn't depend on UI settings. Recommended, given the next point.
- **Auto optimize can switch formats back on.** Auto optimize lets Google run experiments and automatically apply changes, including "Turning on an Auto ads format" and "Changing Auto ads format settings". By default it tests on 50% of traffic. It is set **per site** ([About Auto optimize](https://support.google.com/adsense/answer/9141298)). **Turn it off for howtoedibles.com**, or set it to "apply improvements manually".
- **Never add `data-overlays` to the ad code.** The `data-overlays="bottom"` and `"collapsed-bottom"` edits "switch anchors on even if you've disabled them in your Auto ads settings" ([7478225](https://support.google.com/adsense/answer/7478225)).
- **Do manual units keep serving with Auto ads off?** No source says so explicitly. Auto ads are described as detecting "existing Google ads" and adding ads around them ([About Auto ads](https://support.google.com/adsense/answer/9261805)), and ad units are the publisher-placed alternative that gives "control over where ads appear" ([About ad units](https://support.google.com/adsense/answer/9183549)). **Inference:** manual units keep serving, and `adsbygoogle.js` must stay in `<head>`. **Verify** with the Ad formats report: after the switch, the "Placement methods" breakdown should show only manually placed ads (see §5).

## 2. Mobile placement rules

### Coalition for Better Ads (enforced through Google's Ad Experience Report)

Mobile experiences that fail the standard ([Standards](https://www.betterads.org/standards/)):

- Pop-ups
- Prestitials
- Ad density over 30%
- Flashing animated ads
- Auto-playing video with sound
- Postitials with countdown
- Full-screen scrollovers
- Large sticky ads
- Sticky pop-out video ads

Rules that apply to this site:

- **Density of 30% or less.** The limit applies to ads taking up "more than 30% of the vertical height of a page". Density is the sum of ad heights in the **main content** divided by the main-content height. It is "measured against the main content portion of the page, not the viewport". Headers, footers and navigation are excluded, and related-article links count as navigation. Ads below the main content are "not included". Sticky ads count once. ([Density](https://www.betterads.org/mobile-ad-density-higher-than-30/))
  - *Worked example (inference):* a recipe page with roughly 5,000 px of mobile main content allows up to 1,500 px of ads. Two 280 px units use about 11%. The homepage grid is shorter, so stay at 2 units or fewer there.
- **Sticky ads:** they fail only when they take up "more than 30% of the screen's real estate" ([Large sticky](https://www.betterads.org/mobile-large-sticky-ad/)). A standard 50–100 px anchor is under that. **Inference.**
- **Full-screen scrollover** (an ad over 30% of the page floating on top of content) fails ([Scrollover](https://www.betterads.org/mobile-full-screen-scrollover-ad/)).
- **Check:** Search Console's **Ad Experience Report** (Mobile tab) lists violations such as "high ad density on mobile devices" ([Ad Experience Report](https://support.google.com/webtools/answer/7159932)).

### AdSense ad placement policies ([1346295](https://support.google.com/adsense/answer/1346295))

- Ads must not be placed where they could be "mistaken for other site content, such as a menu, navigation, or download links". That "includes formatting neighboring content to look similar to the ads." → Don't style recipe cards or chips like ads, or ads like cards.
- "Be careful when placing links, play buttons, download buttons, navigation buttons... drop-down menus... near ads." Accidental clicks can trigger a violation "even if the layout unintentionally leads to accidental clicks." **No numeric spacing rule exists for web content.** The only figure is 150 px, and it applies to games and Flash players ([1346295](https://support.google.com/adsense/answer/1346295), [11191353](https://support.google.com/publisherpolicies/answer/11191353)).
  - → The current unit sits directly under the search input. Move it away from the search box, the calculator controls, the dark-mode toggle and the "Next/Previous" or pagination buttons.
- **Labels:** only "Advertisements" or "Sponsored Links". No arrows or other attention-grabbing ([1346295](https://support.google.com/adsense/answer/1346295)).
- **Count:** there's no fixed limit. The rule is "you don't place more ads than content" ([Best practices](https://support.google.com/adsense/answer/1282097)).

### Modifications and behavioral restrictions

- Prohibited ([Modifying ad code](https://support.google.com/adsense/answer/1354736)):
  - ads that slide or zoom ("ads sliding into the screen, ads zooming in/out")
  - code that covers content, or content that covers ads
  - layouts where "content and ads... overlap" on mobile or responsive sites
  - hiding units with `display:none`, "unless you're implementing a responsive ad unit"
- Restrictions:
  - Google-served ads must not "fully or partially obscure content" ([11127388](https://support.google.com/publisherpolicies/answer/11127388)).
  - Content must not obscure ads ([11191353](https://support.google.com/publisherpolicies/answer/11191353)).
  - → **A sticky header or bottom nav in the redesign must never overlap an ad slot.** Inference: a fixed header covering an in-flow ad while scrolling is the risk case.
- **Sticky manual unit (DIY anchor): don't build one.** "Generally, altering the behavior or targeting of AdSense ad code is prohibited" ([1354742](https://support.google.com/adsense/answer/1354742)). The only sanctioned anchor is the Auto ads one.

### Anchor ads: keep or drop?

- Anchors are an **Auto ads overlay format**. They "stick to the edge of the user's screen and are easily dismissible", default to the top, and top anchors appear only after scrolling. Dynamic anchors "can expand to be larger than standard anchors" and are "frequency capped per user on mobile" ([About anchor ads](https://support.google.com/adsense/answer/15484692)).
- So keeping an anchor means keeping Auto ads on with just that one format enabled. That contradicts the manual-only decision.
- **Recommendation: no anchor at launch.** If the revenue drop (see §5) is unacceptable, the anchor is the least intrusive way back. It reserves no layout space and has no CLS or density impact. Test it with an Auto ads experiment where the anchor is the only format on, and keep `google-anno-skip` on `<body>`.

### Search ranking side note

Google Search advises "Don't obscure the entire page with interstitials" and prefers banners "that take up only a small fraction of the screen" ([Intrusive interstitials](https://developers.google.com/search/docs/appearance/avoid-intrusive-interstitials)). That's another reason to keep vignettes off.

## 3. Reserving space for responsive units (CLS)

- **Target:** CLS of 0.1 or less for at least 75% of visits. Above 0.25 is poor. Ads are "one of the largest contributors to layout shifts on the web." ([web.dev Optimize CLS](https://web.dev/articles/optimize-cls))
- **Reserve space in CSS:** use `min-height`, or `aspect-ratio` for responsive slots, with media queries per form factor. Choose the largest size, or the "most likely size... based on historical data". Content injected near the top of the viewport "usually causes greater layout shifts", so place slots lower if space can't be reserved. Don't collapse the reserved space when no ad returns: "Removing the space... can cause just as much CLS as inserting content." ([web.dev](https://web.dev/articles/optimize-cls))
- Google's own ad-tag guide agrees: "The only guaranteed way to avoid layout shift is to reserve a sufficient amount of space... using CSS". It gives `style="min-width: 300px; min-height: 250px;"` as the example and says "Reserving space with JavaScript should be avoided" ([GPT: minimize layout shift](https://developers.google.com/publisher-tag/guides/minimize-layout-shift)).
- **Fixed-size option (sanctioned):** AdSense lets you set exact sizes per breakpoint with a `<style>` block on the page. Remove `data-ad-format="auto"` and `data-full-width-responsive="true"`, then set the size, for example `.slot { width: 320px; height: 100px }` with larger sizes in media queries. Google calls this "acceptable". CSS in external stylesheets "is not officially supported", so keep it inline or in a page `<style>` block. Each slot needs a unique class name. ([Modify responsive ad code](https://support.google.com/adsense/answer/9183363))
- **Trade-off:** Google says full-width responsive "has the maximum potential for increased revenue" on mobile, and setting it to `false` means "you may decrease your potential earnings" ([9183460](https://support.google.com/adsense/answer/9183460)).

**Recommendation for the redesign:**

1. Keep `data-full-width-responsive="true"` on mobile. Wrap each `<ins>` in a container with a **`min-height` of 280px** on mobile.
   - **Inference:** 280px covers 300x250 and 336x280, the common mobile rectangles. Check the actual served heights in DevTools on a few pages and adjust to the most common one.
2. Never place a slot in the first viewport above the hero or title. Move today's top-of-page unit below the fold. That alone removes the worst CLS case.
3. Leave the reserved space when the slot doesn't fill. Show a neutral placeholder; don't collapse it.
4. If CrUX or Search Console Core Web Vitals still shows mobile CLS above 0.1, switch the mobile slot to a fixed `300x250` with the sanctioned inline-CSS method.

## 4. "Restricted content" and how many units are worth it

- Marijuana is named under **Recreational drugs** in Google Publisher Restrictions. Restricted content is anything that "promotes substances that alter mental state for the purpose of recreation", with "marijuana" among the listed examples, or "provides instructions on producing, purchasing, or using recreational drugs". Monetized restricted content gets "restricted ad serving". ([Recreational drugs](https://support.google.com/publisherpolicies/answer/10436831))
  - The page also shows that "educational material about recreational drugs" can carry ads "unrestricted". The examples are images, so the exact boundary isn't stated.
  - Inference: edible recipes are "instructions on producing... or using", so expect them to stay restricted. Harm-reduction articles might not be.
- What restricted means in practice ([Publisher Restrictions](https://support.google.com/adsense/answer/10437795)):
  - "fewer advertising sources will be eligible to bid on it".
  - "**Google Ads... advertisements will not serve** on content labeled with these restrictions".
  - Sometimes "no advertising sources are bidding on your inventory and no ads will appear".
  - The content "will likely receive less advertising than other, nonrestricted content."
- **This is not the same as "Limited ads".** Limited ads (LTD) means serving without personal data for personalization, driven by consent or CMP signals. "Limited ad serving" is an account-level cap on volume, usually for traffic-quality reasons, and it shows in the Policy center ([14668281](https://support.google.com/adsense/answer/14668281), [14210870](https://support.google.com/adsense/answer/14210870)). The "limited ads" wording found by map #39 should be read as **restricted ad serving**, meaning reduced demand with no Google Ads advertisers.
- **How many units:** no source gives a number for restricted inventory.
  - **Inference:** with Google Ads demand excluded, fill is the binding constraint, not slot count. Extra slots mostly come back unfilled or low-CPM, and each one adds CLS and density cost.
  - **Recommendation:**
    - **Recipe pages: 2 units.** One after the intro or summary and before the ingredients, below the fold. One after the instructions and before the FAQ or related recipes.
    - **Homepage: 1 unit** inside the grid after the first row or two of cards. Make it visibly distinct from the cards and labeled "Advertisements".
    - **Articles: 1–2 units.**
  - Add a third recipe unit only if the reports show the two existing slots fill well and page RPM goes up.

## 5. Measuring the revenue impact

1. **A/B test before the switch (best signal).** Go to **Optimization → Experiments → Auto ads card → Create new experiment**, pick the site, set the variation to Auto ads off, then **Start experiment** → **Run experiment**.
   - Metrics reflect "the impact across your entire site (including any ad units you're using)".
   - Only one Auto ads experiment can run per site at a time.
   - Results appear after "a few days".
   - ([Auto ads experiments](https://support.google.com/adsense/answer/9726342))
   - The "Apply to site → Run experiment first" path runs "on 50% of your site's traffic for 90 days" ([9261307](https://support.google.com/adsense/answer/9261307)).
   - Run this on the *current* layout so the Auto ads effect is isolated from the redesign effect.
2. **Before/after reports.**
   - **Reports → Ad formats:** the "Placement methods" breakdown splits manually placed ads from automatically placed ones (anchors, vignettes) ([9974244](https://support.google.com/adsense/answer/9974244)). This gives today's Auto ads share of earnings, the amount at risk.
   - Add **+ add comparison** → Previous period / Previous year / Custom, with equal-length ranges ([9831228](https://support.google.com/adsense/answer/9831228)).
   - Use the **Platforms** breakdown to isolate mobile ([9830627](https://support.google.com/adsense/answer/9830627)).
   - **Ad units** and **Top pages** reports give per-unit and per-page results ([9974595](https://support.google.com/adsense/answer/9974595), [11988479](https://support.google.com/adsense/answer/11988479)).
   - Compare **earnings per page view (page RPM)**, not raw earnings. Traffic is moving at the same time.
3. **Don't let a comparison window span 17 Feb 2027.** On that date AdSense switches display impressions from count-on-download to **begin-to-render**, and publishers "may notice a decrease in total display impressions" ([16896667](https://support.google.com/adsense/answer/16896667)). Compare earnings and page RPM, not impression counts. Ship the manual-only switch, and close its measurement window, well before or well after that date.
4. Add a note on the date chart when you flip the settings. Date-broken-down charts support notes ([9831227](https://support.google.com/adsense/answer/9831227)).

---

## Actionable summary for the redesign

| Question | Answer |
|---|---|
| Units per page | Recipe: 2. Home: 1 (in-grid). Articles: 1–2. Restricted demand means more slots mostly add unfilled space. |
| Where on mobile | Below the first viewport, never above hero or title. One after intro/before ingredients, one after instructions. Keep away from search, calculator inputs, pagination and nav. Never under a sticky header or bottom bar. Labeled only "Advertisements" or "Sponsored Links". Keep density ≤30% of main content. |
| Reserved size | Container `min-height: 280px` on mobile (verify the most common served height). No collapse on no-fill. Fallback is a sanctioned fixed 300x250 via inline `<style>`. |
| Anchor ad | No at launch. It's an Auto ads format. If revenue falls too far, test an anchor-only Auto ads experiment as the first rollback. |
| Turn off formats | Ads → Edit site: Auto ads off. Also uncheck ad intents (links, anchors, chips) and turn off anchor, vignette, side rail, banner, Multiplex and Existing ads. Related search is already gone (6 Aug 2026). Turn **Auto optimize off** for the site. Add `google-anno-skip` to `<body>`. Never use `data-overlays`. |
| Measure | Auto ads on-vs-off experiment on the current layout first. Then Ad formats report (Placement methods) + Platforms = mobile + page RPM with date comparison. Keep windows off 17 Feb 2027. |
