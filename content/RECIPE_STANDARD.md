# How to write a recipe for HowToEdibles

Rules for adding a recipe or editing one, in all 5 languages. They come from the 2026-11 recipe review (#111–#116). That review found real doses up to 5× the sticker, cheesecake "at room temperature for 5 days", and pages with four different shelf lives. Every rule below exists because a page broke it.

Check your work with `ruby scripts/qa/recipes.rb .`: pass/fail per recipe and language on the checks below. Fix every new failure before you open the PR.

## 1. Where a recipe lives

| What | File |
|---|---|
| English name, description, ingredients, steps (HTML `<li>`), `suggested_quantity` (g of flower), `suggested_portion` (servings), category | `data/recipes.json` |
| Times, `base_fat`, `cook_temp`, `sub_category` (which template), the recipe's own sentences: `intro_unique`, `dosing_unique`, `storage_unique`, `variation_unique`, and its own FAQ `faq_unique` (`[{"q", "a"}]`, plain text, shown before the template FAQ) | `data/recipe_enrichment.json` |
| pt/es/de/zh name, description, ingredients, steps: **one line per English line, same order, same count** | `i18n/recipes_{lang}.json` |
| Template text shared by every recipe of a `category/sub_category` (intro, tips, mistakes, storage, variations, FAQ) | `i18n/recipe_sections_{lang}.json` |

The page shows the template lines first and then the recipe's own sentence, so the recipe always has the last word.

## 2. Dose: the rule that matters most

**The page doses exactly what the reader gets when they make the recipe with the site's own base recipe**, the one the ingredient links to. Never write "(made with X g)" next to an infused ingredient: readers use the base they already made.

```
real grams of flower = (cups of infused base in the recipe) × (grams per cup of that base)
mg per serving      = 10 × grams × 14 (% THC, DEFAULT_THC) × 0.8 (COOKING_EFFICIENCY) / servings
```

Base strengths (grams of flower per cup of finished base):

| Base | g per cup | Per tbsp | Per tsp |
|---|---|---|---|
| Cannabutter | 6.4 | 0.4 | 0.133 |
| Infused coconut oil | 6.4 | 0.4 | 0.133 |
| Infused olive oil | 6.3 once #113 merges (8 g / 300 ml); 1.6 until then (2 g / 300 ml) | 0.39 | 0.13 |
| Infused ghee | 3.5 | 0.22 | — |
| Infused honey (½ cup oil + 300 g honey ≈ 1.4 cups) | 2.5 | 0.156 | — |
| Infused milk / cream (1 g per litre) | 0.237 | — | — |
| Cannabis sugar / flour | 6.4 | 0.4 | — |
| Tincture (7 g in 4 oz alcohol) | 14 | — | — |

By weight, cannabutter holds 0.028 g of flower per gram of butter (6.4 g in 227 g).

Rules:
- **≤ 15 mg per serving** at the default (14% THC). Aim for 10–15 mg.
- **Hit the target by splitting the fat, not by changing the dish.** If the recipe needs 200 g of butter and the dose needs 35 g of cannabutter, write `35g cannabutter + 165g unsalted butter, cold, cubed`. The total fat stays what the dish needs.
- **`suggested_quantity` = the real grams** the infused amount holds, rounded so the sticker doesn't round above 15 (2 tsp of coconut oil holds 0.267 g; store 0.26, not 0.27, which would show 15.1 mg).
- **No base, no recipe.** Sesame oil, vegetable oil, syrups and spirits have no base recipe on the site. Carry the dose in a base (infused coconut oil + toasted sesame oil for flavour), or add the base recipe first.
- **No ranges** ("1–2 tsp infused oil"): the dose must be one number.
- **When the infused fat is split** (in dough and brushed on, or two layers), say which part goes where, and if two fats go in together, say "melted together".
- Write `cannabutter` (or `manteiga de cannabis`, `mantequilla de cannabis`, `Cannabutter`, `大麻黄油`) so the build links the line to the base recipe. In English, put the infused coconut / olive oil in an `<a class="recipe-reference" href="/recipes/infused-coconut-oil/">` link.
- Direct-flower recipes (whiskey, tincture, chai, hot sauce) put the flower amount in `<span id="grams-quantity-recipe">`; the build fills it from `suggested_quantity`.

## 3. The recipe must work in a kitchen

- **Proportions** stay within what a trusted source uses for that kind of dish (King Arthur, Serious Eats, Bon Appétit). Cite the source in the PR when you change proportions; don't invent numbers.
- **Pan size, time and temperature** fit each other: a thinner layer in a bigger pan bakes faster.
- **Every listed ingredient appears in a step**, and every step-time is in `totalTime`, chilling and overnight included. `totalTime` is ISO `PT#H#M`: no days (`P2D` shows as 5 min).
- **Steps in order and complete:** melt the butter before "mix the melted butter", cool before cutting, bloom gelatin before heating it.
- **Even dose:** mix the infused fat in fully; for drinks, stir or shake before pouring; for candy and gummies, an emulsifier (lecithin) in a step, not just in the list.
- **Say what one serving is**, in a step or `dosing_unique`: "cut into 16 squares", "1 serving = 1 teaspoon", "pour into 2 glasses". The number must equal `suggested_portion`.
- **Raw egg** (tiramisu, eggnog whites, mousse): say "pasteurized".

## 4. Food safety and storage

- **The recipe's `storage_unique` is the page's only shelf life.** Template storage lines carry no durations, only the three shared rules (§6). Don't add another duration in a tip or FAQ.
- **Anything with dairy, eggs, cream cheese, meat or fish goes into the fridge within 2 hours of cooking** (1 hour above 90°F / 32°C). Source: FDA, "Are You Storing Food Safely?".
- Fridge times: use the FDA Refrigerator & Freezer Storage Chart (fda.gov/media/74435). Cooked meat, poultry, fish and soups or stews: 3–4 days.
- **Room temperature is only for** fully baked, low-moisture goods without fresh-dairy fillings or frosting: brownies, cookies, quick breads, fruit pies, baklava. King Arthur keeps fudge brownies 5–6 days, wrapped. Cheesecake, custard pies (pumpkin, pecan, key lime), cream-cheese frosting, cream fillings and ganache go in the fridge.
- Infused oils, honey and tinctures are the long-keeping ones; butter-based bases go in the fridge or the freezer.

## 5. Templates (`sub_category`)

Choose the template by **how the dish is cooked**, not by its name. The template text must be true for this recipe:

| The dish | Template |
|---|---|
| Baked in the oven | `baked_goods`, `keto_baked`, `vegan_baked`, `savory_bites`… |
| Never baked; sets in the fridge (krispie treats, tiramisu) | `Desserts/no_bake` |
| Pan-cooked or fried dessert (french toast, crepes, churros, donut holes, pancakes) | `Desserts/stovetop` |
| Drink served cold | `Drinks/cold_drinks` (or `citrus`, `fruity`) |
| Drink served hot | `Drinks/hot_drinks` |
| Steeped hot tea | `Drinks/herbal_tea` |

Other rules:
- **Borrowing another category's template:** a recipe can use one by naming it: `"sub_category": "Desserts/stovetop"`.
- **`base_fat`** is the infused ingredient the recipe really uses ("infused honey", not "cannabis simple syrup"). It's interpolated into the templates, in English.
- **`cook_temp`** is the oven temperature from the steps ("425°F / 220°C"); templates put it after "bakes at".

## 6. Writing template text (`recipe_sections_{lang}.json`)

A template line lands on every recipe of its sub-category. Before you write one, check it against each of them.

- **No durations in storage lines.** Every storage list is the same three rules: follow the recipe's note; dairy/eggs/meat/fish in the fridge within 2 h; freeze single labelled portions; label and keep from children.
- **No numeric claims you can't source.** "THC degrades above 350°F" contradicted recipes baked at 375–425°F; the inside of a cake stays far cooler than the oven.
- **Dose advice must agree with the sticker and the beginner line:** first time, about 5 mg (⅓ of a 15 mg serving), and wait 2 hours.
- **No health or absorption claims** ("anti-inflammatory", "immune-boosting", "improves THC absorption") without a source (#115).
- **No other dish's name** in a shared line ("strudel and kuchen keep 3 days" landed on schnitzel).
- **Translations: don't use `%{base_fat}`**, because its value is English. Write "o ingrediente com cannabis", "el ingrediente con cannabis", "die Cannabis-Zutat", "含大麻的配料". Avoid gendered articles before `%{name}` ("esta receita de %{name}").
- **The same index in every language**: line *i* of a list says the same thing in all five files.

## 7. Translations

- **Same lines:** `ingredients` and `instructions` have the same number of lines as English, in the same order, with the same numbers. Converted units are fine (°F → °C, cup → ml, in → cm).
- **No English left over:** "1 cup de manteiga" fails. Use the language's own units and words.
- **The own sentences** (`intro_unique`, `dosing_unique`, `storage_unique`, `variation_unique`) belong in `i18n/recipes_{lang}.json` too, with `unique_src` = SHA1 of the 4 English fields joined by "\n". Without a translation they fall back to English (#92).
- **The own FAQ** (`faq_unique`) goes in `i18n/recipes_{lang}.json` with the same questions in the same order, and `faq_src` = SHA1 of `JSON.generate` of the English `faq_unique`. Without a translation the page shows only the template FAQ, never English questions (#116). The build warns when either hash is stale.
- **FAQ answers follow the same rules as any own sentence:** no shelf life (that is `storage_unique`), the dose matches the sticker, no health claims.

## 8. Before the PR

```bash
ruby scripts/qa/recipes.rb . --json /tmp/l1.json   # no new failures on the recipes you touched
ruby scripts/build_site.rb                          # inbound links, budget
python3 -I scripts/qa/serve.py 8781 & node scripts/qa/devices.mjs && node scripts/qa/fit.mjs
```

In the PR, give the dose before and after for every recipe you touched, and the source for any proportion, time or storage change.
