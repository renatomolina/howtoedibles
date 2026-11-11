# Translating the recipe sentences that still show in English (#92)

**Pipeline** (run from the repo root): `ruby content/translations/recipes/prep.rb [slug …]` writes the inputs to `tmp/unique/`. One translator per language and part follows this brief. Then `ruby content/translations/recipes/merge.rb` validates and merges into `i18n/recipes_{lang}.json` and `i18n/recipe_vars.json`, and `ruby scripts/build_site.rb` rebuilds. The first run (2026-11-11) used 8 translators: 4 languages × parts 1 and 2. When the build warns that a translation is stale or that a vars value is missing, pass just those slugs to prep.rb (they all land in part 1), and translate the vars only if the warning names one.

---

Root: the repo root, or the worktree you're given (call it ROOT). Work only by reading files and writing your output file(s) in `ROOT/tmp/unique/`. Don't run git, and don't edit any other file.

HowToEdibles is a cannabis edibles recipe site. Every recipe page has four sentences of its own (intro, dosing tip, storage tip, variation) that would otherwise render in English on the translated pages. The topic involves doses and food safety, so **fidelity matters more than flair**.

## Your input
`ROOT/tmp/unique/en-{part}.json`: `{ slug: { name, intro_unique, dosing_unique, storage_unique, variation_unique } }`. `name` is the English recipe name, for context only.
For the recipe's name *in your language*, and the terms the page already uses, read `ROOT/i18n/recipes_{lang}.json` → `[slug].name` / `ingredients` / `instructions`. When a sentence names the recipe, use that translated name so the page agrees with its own H1.

## Your output
`ROOT/tmp/unique/{lang}-{part}.json`: the same slugs, each with exactly the 4 keys `intro_unique`, `dosing_unique`, `storage_unique`, `variation_unique` (no `name`). Valid UTF-8 JSON, 2-space indent. Every slug of the input, every key non-empty.
Write the file in a few chunks if needed (e.g. write the first 40 slugs, then rewrite the file with 80, then all), but the final file must hold all of them.

## Rules
- Translate the meaning faithfully. **Don't change any number, dose, temperature, time, weight, ratio, percentage, or hedge.** Keep units as written (mg, g, °F/°C, tsp/tbsp may become the local word, but keep the number). Don't add advice; don't drop warnings.
- Keep brand/product names and "THC", "CBD", "HowToEdibles".
- Plain text only (the source has no HTML; don't add any).
- Write like a native food editor: natural, concise, not literal.

## Voice and terminology (match the site)
- **pt (Brazilian Portuguese):** "você". Edibles = "comestíveis", serving = "porção", cannabutter = "manteiga de cannabis". Prefer "cannabis" ("maconha" only where natural). Decimal comma (2,5 mg). Infused = "infusionado/a" as in the existing recipe names.
- **es (neutral Latin American Spanish):** "tú". "comestibles", "porción", "mantequilla de cannabis", "cannabis". Decimal comma.
- **de:** informal **"du"** (the recipe templates use "du/dein"). "Edibles", "Portion", "Cannabutter". Decimal comma. Correct compounds.
- **zh (Simplified Chinese):** "你". "大麻食品", cannabutter = "大麻黄油"; THC/CBD stay Latin. Full-width punctuation. Decimal point.

## Part 1 only: the template variables
Part 1 also writes `ROOT/tmp/unique/{lang}-vars.json`, translating every value in `ROOT/tmp/unique/en-vars.json`:
```json
{ "base_fat": { "<English value>": ["<translation>", "<gender>"] }, "cook_temp": { "<English value>": "<translation>" } }
```
These values are dropped into the translated templates in `ROOT/i18n/recipe_sections_{lang}.json` at `%{base_fat}` and `%{cook_temp}`. Grep that file for both placeholders and read a dozen sentences, so your translations read well *in those slots*. For example, pt "assa perfeitamente a %{cook_temp}", "Mantenha o forno a %{cook_temp} ou abaixo"; de "bei %{cook_temp}".
- `base_fat`: a noun phrase (lowercase unless German nouns require capitals) with its grammatical gender: pt/es `"m"` or `"f"`, de `"m"`, `"f"` or `"n"`, zh `""`. Templates put a determiner right before the slot (pt "o/seu/do", es "el/del/un", de "das/dein/deinem"). The build fixes the determiner from your gender, so the gender must be that of the phrase's head noun. For de, prefer a neuter phrase when it's just as natural (e.g. "Cannabis-Öl").
- `cook_temp`: a short phrase that fits "at …" slots. Temperatures keep both units as written (e.g. "350 °F / 175 °C" style is fine). Values like "no_cook", "stovetop", "simmer" become a natural phrase ("sem cozimento", "no fogão", "fogo baixo").
- Every English value must appear as a key, spelled exactly as in en-vars.json.

## Before you finish
Re-read your file against the English for meaning, especially numbers and warnings, and check it parses (`ruby -rjson -e 'JSON.parse(File.read(ARGV[0]))' FILE`). Reply with one line: the file(s) written, slug count, and anything you weren't sure about.
