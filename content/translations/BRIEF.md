# Translating the 22 missing articles

**Goal.** Each English article in `content/translations/en/{slug}.json` becomes `content/translations/{lang}/{slug}.json`, with exactly the same JSON shape. The entries later merge into `i18n/articles_{lang}.json` and are rendered by `build_article_page` in `scripts/build_site.rb`. Today these URLs show English text, or the wrong article duplicated. This is a cannabis edibles site, and many of these articles are health, legal or safety topics (YMYL), so **fidelity matters more than flair**.

Work only inside `/Users/renato/Projects/howtoedibles/.claude/worktrees/translations/`. Don't run git, don't edit anything outside `content/translations/{lang}/`, and don't touch other languages' files.

## What to translate
- `title`, `description` (the meta description: keep it about as long as the English, ≤ 160 characters), `excerpt`.
- `keywords`: a comma-separated list of the natural search terms a native speaker would type. Don't translate the English list word by word.
- `toc[].text`, every visible text node in `body_html`, `faq[].question` and `faq[].answer`, and `related[].title` and `related[].description`.

## What must stay identical
- `date_published`, `date_modified` and `toc[].id`, in the same order.
- `related[].slug`.
- **All HTML in `body_html`:** every tag, attribute, `id`, `class` and `href`, in the same order. Translate only the text between tags. Don't add, drop, merge or split elements. Internal links stay pointing at the English URLs, and a later script localises them.
- **Sources section** (`<h2 id="sources">…`): translate the heading and any connecting words. Keep the cited titles, authors, publishers and journal names exactly as written.
- Brand and product names, "HowToEdibles", "CBD", "THC", "CBN", strain names, units (mg, g, ml, °F/°C) and every number. **Don't change any fact, dose, percentage, law, date or hedge.** Don't add advice and don't drop warnings.

## Fixed labels
| | pt | es | de | zh |
|---|---|---|---|---|
| category Edibles / Health / Wellness / Culture / Guides / Science | Comestíveis / Saúde / Bem-estar / Cultura / Guias / Ciência | Comestibles / Salud / Bienestar / Cultura / Guías / Ciencia | Edibles / Gesundheit / Wellness / Kultur / Ratgeber / Wissenschaft | 食品 / 健康 / 养生 / 文化 / 指南 / 科学 |
| `read_time` for "N min read" | `N min de leitura` | `N min de lectura` | `N Min. Lesezeit` | `N分钟阅读` |

## Voice and terminology (match the site's existing translated articles)
- **pt (Brazilian Portuguese):** "você". Edibles are "comestíveis", a serving is "porção", cannabutter is "manteiga de cannabis". Prefer "cannabis", with "maconha" only where it sounds natural. Decimal comma (2,5 mg).
- **es (neutral Latin American Spanish):** "tú". "comestibles", "porción", "mantequilla de cannabis", "cannabis" (with "marihuana" only occasionally). Decimal comma.
- **de:** formal **"Sie / Ihr"**, as in the site's other German articles. "Edibles" or "Cannabis-Edibles" as the loanword, "Portion", "Cannabutter". Decimal comma. German noun capitalisation and correct compounds.
- **zh (Simplified Chinese):** "你", not "您". Edibles are "大麻食品" and THC/CBD stay Latin. Use full-width punctuation in prose. Decimal point.
- Write the way a native editor would: natural sentences, concise headings, not literal. Keep the structure: short answer box, info boxes and lists as they are.

## JSON
Write valid UTF-8 JSON (2-space or 1-space indent is fine). Escape the double quotes inside `body_html` (`\"`). Use typographic quotes in the prose: „…“ in de, “…” in pt/es, “…” in zh.

## Check every file before moving on
```
python3 -I /Users/renato/Projects/howtoedibles/.claude/worktrees/translations/content/translations/validate.py /Users/renato/Projects/howtoedibles/.claude/worktrees/translations/content/translations {lang}/{slug}
```
It must print `✓`. Fix every `✗`: structure, ids, hrefs, category, read_time, leftover English, or a suspicious length ratio. Then reread your translation once for meaning against the English, especially doses, warnings and legal statements.
