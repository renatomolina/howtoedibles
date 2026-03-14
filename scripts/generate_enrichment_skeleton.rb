#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates data/recipe_enrichment.json from data/recipes.json
# Run: ruby scripts/generate_enrichment_skeleton.rb

require 'json'

DATA_DIR = File.expand_path('../data', __dir__)
INPUT    = File.join(DATA_DIR, 'recipes.json')
OUTPUT   = File.join(DATA_DIR, 'recipe_enrichment.json')

recipes_data = JSON.parse(File.read(INPUT))

# ── Sub-category assignment ──────────────────────────────────────────────────

SUB_CATEGORIES = {
  'desserts' => {
    'baked_goods' => %w[cookies brownies bread cake cobbler pie bars blondies rolls baklava donut gingerbread],
    'frozen'      => %w[sorbet ice-cream],
    'confections' => %w[truffles gummy fudge caramel honey fondue krispie macaroon],
    'pastries'    => %w[churros crepes shortcake tiramisu],
    'puddings'    => %w[panna-cotta pudding cheesecake]
  },
  'drinks' => {
    'hot_drinks'  => %w[chai hot-chocolate eggnog],
    'cold_drinks' => %w[smoothie lemonade cold-brew],
    'alcoholic'   => %w[whiskey]
  },
  'snacks' => {
    'savory_snacks' => %w[grilled-cheese popcorn firecrackers],
    'sweet_snacks'  => %w[energy-bites trail-mix granola],
    'dips'          => %w[guacamole hummus]
  },
  'essentials' => {
    'butter_oil' => %w[cannabutter olive-oil coconut-oil ghee],
    'milk_cream' => %w[milk condensed-milk]
  },
  'lunch' => {
    'pasta_rice'     => %w[pesto-pasta spaghetti risotto fried-rice pad-thai],
    'soup'           => %w[minestrone bisque butternut-squash-soup],
    'salad'          => %w[caesar-salad greek-salad caprese-salad],
    'sandwich_wrap'  => %w[avocado-toast tacos sliders falafel-wrap quesadilla burrito-bowl pizza],
    'main_dish'      => %w[coconut-curry shakshuka thai-basil-chicken grilled-salmon lentil-dal salad-dressing]
  },
  'keto' => {
    'keto_baked'  => %w[cookies cheesecake-bites waffles almond-flour-cake cauliflower-pizza],
    'keto_sweet'  => %w[fat-bombs chocolate-bark avocado-mousse],
    'keto_savory' => %w[bacon-bites chicken-wings deviled-eggs stuffed-mushrooms beef-chili zucchini-chips salmon-patties spinach-dip],
    'keto_drink'  => %w[bulletproof-coffee]
  },
  'vegan' => {
    'vegan_baked'  => %w[brownies pancakes],
    'vegan_sweet'  => %w[chocolate-mousse ice-cream banana-ice-cream protein-balls],
    'vegan_savory' => %w[cheese-sauce lentil-soup curry jackfruit-tacos mac-and-cheese chickpea-stew pesto-zoodles black-bean-soup roasted-vegetable]
  },
  'mocktails' => {
    'citrus'     => %w[sparkling-lemonade lavender-lemonade rose-lemonade passion-fruit-lemonade cherry-limeade blueberry-lemonade],
    'fruity'     => %w[watermelon-slush tropical-punch strawberry-basil-smash cranberry-spritzer mango-lassi pineapple-ginger-fizz coconut-lime-agua-fresca],
    'herbal_tea' => %w[virgin-mojito cucumber-mint-cooler hibiscus-tea peach-iced-tea matcha-cooler mint-green-tea ginger-turmeric-tonic]
  },
  'international' => {
    'brazilian_sweet'  => %w[brigadeiro pacoca beijinho],
    'brazilian_savory' => %w[feijoada coxinha pao-de-queijo acai-bowl moqueca tapioca-crepe empadao]
  }
}

def find_sub_category(slug, category_slug)
  subs = SUB_CATEGORIES[category_slug] || {}
  subs.each do |sub_cat, patterns|
    patterns.each do |pat|
      return sub_cat if slug.include?(pat)
    end
  end
  'other'
end

# ── Defaults by category / sub_category ──────────────────────────────────────

def time_defaults(category, sub_cat)
  case category
  when 'desserts'
    case sub_cat
    when 'baked_goods'  then ['PT15M', 'PT35M', 'PT50M']
    when 'frozen'       then ['PT15M', 'PT0M',  'PT4H15M']
    when 'confections'  then ['PT20M', 'PT15M', 'PT35M']
    when 'pastries'     then ['PT20M', 'PT25M', 'PT45M']
    when 'puddings'     then ['PT20M', 'PT30M', 'PT50M']
    else                     ['PT15M', 'PT30M', 'PT45M']
    end
  when 'drinks'
    case sub_cat
    when 'hot_drinks'  then ['PT5M',  'PT10M', 'PT15M']
    when 'cold_drinks' then ['PT10M', 'PT0M',  'PT10M']
    when 'alcoholic'   then ['PT5M',  'PT0M',  'PT14D']
    else                    ['PT10M', 'PT5M',  'PT15M']
    end
  when 'snacks'       then ['PT10M', 'PT15M', 'PT25M']
  when 'essentials'   then ['PT10M', 'PT45M', 'PT55M']
  when 'lunch'
    case sub_cat
    when 'soup'           then ['PT15M', 'PT30M', 'PT45M']
    when 'salad'          then ['PT15M', 'PT0M',  'PT15M']
    when 'pasta_rice'     then ['PT10M', 'PT25M', 'PT35M']
    when 'sandwich_wrap'  then ['PT15M', 'PT20M', 'PT35M']
    when 'main_dish'      then ['PT15M', 'PT30M', 'PT45M']
    else                       ['PT15M', 'PT25M', 'PT40M']
    end
  when 'keto'
    case sub_cat
    when 'keto_baked'  then ['PT15M', 'PT25M', 'PT40M']
    when 'keto_sweet'  then ['PT15M', 'PT10M', 'PT25M']
    when 'keto_savory' then ['PT15M', 'PT25M', 'PT40M']
    when 'keto_drink'  then ['PT5M',  'PT5M',  'PT10M']
    else                    ['PT15M', 'PT20M', 'PT35M']
    end
  when 'vegan'
    case sub_cat
    when 'vegan_baked'  then ['PT15M', 'PT30M', 'PT45M']
    when 'vegan_sweet'  then ['PT15M', 'PT10M', 'PT25M']
    when 'vegan_savory' then ['PT15M', 'PT25M', 'PT40M']
    else                     ['PT15M', 'PT25M', 'PT40M']
    end
  when 'mocktails'     then ['PT10M', 'PT0M',  'PT10M']
  when 'international'
    case sub_cat
    when 'brazilian_sweet'  then ['PT20M', 'PT20M', 'PT40M']
    when 'brazilian_savory' then ['PT20M', 'PT40M', 'PT1H']
    else                         ['PT15M', 'PT30M', 'PT45M']
    end
  else                      ['PT15M', 'PT30M', 'PT45M']
  end
end

def nutrition_defaults(category, sub_cat)
  case category
  when 'desserts'
    case sub_cat
    when 'baked_goods' then { 'calories' => '280 kcal', 'fatContent' => '14 g' }
    when 'frozen'      then { 'calories' => '180 kcal', 'fatContent' => '8 g' }
    when 'confections' then { 'calories' => '220 kcal', 'fatContent' => '12 g' }
    when 'pastries'    then { 'calories' => '300 kcal', 'fatContent' => '16 g' }
    when 'puddings'    then { 'calories' => '260 kcal', 'fatContent' => '15 g' }
    else                    { 'calories' => '250 kcal', 'fatContent' => '13 g' }
    end
  when 'drinks'        then { 'calories' => '120 kcal', 'fatContent' => '5 g' }
  when 'snacks'
    case sub_cat
    when 'savory_snacks' then { 'calories' => '220 kcal', 'fatContent' => '12 g' }
    when 'sweet_snacks'  then { 'calories' => '200 kcal', 'fatContent' => '10 g' }
    when 'dips'          then { 'calories' => '150 kcal', 'fatContent' => '11 g' }
    else                      { 'calories' => '200 kcal', 'fatContent' => '11 g' }
    end
  when 'essentials'     then { 'calories' => '100 kcal', 'fatContent' => '11 g' }
  when 'lunch'
    case sub_cat
    when 'soup'  then { 'calories' => '220 kcal', 'fatContent' => '10 g' }
    when 'salad' then { 'calories' => '180 kcal', 'fatContent' => '12 g' }
    else              { 'calories' => '350 kcal', 'fatContent' => '16 g' }
    end
  when 'keto'           then { 'calories' => '250 kcal', 'fatContent' => '22 g' }
  when 'vegan'
    case sub_cat
    when 'vegan_sweet' then { 'calories' => '190 kcal', 'fatContent' => '10 g' }
    else                    { 'calories' => '240 kcal', 'fatContent' => '12 g' }
    end
  when 'mocktails'      then { 'calories' => '80 kcal',  'fatContent' => '0 g' }
  when 'international'
    case sub_cat
    when 'brazilian_sweet'  then { 'calories' => '230 kcal', 'fatContent' => '10 g' }
    when 'brazilian_savory' then { 'calories' => '320 kcal', 'fatContent' => '16 g' }
    else                         { 'calories' => '270 kcal', 'fatContent' => '13 g' }
    end
  else                       { 'calories' => '250 kcal', 'fatContent' => '13 g' }
  end
end

def base_fat(category, sub_cat, slug)
  return 'cannabutter' if slug == 'cannabutter'
  return 'infused olive oil' if slug == 'infused-olive-oil'
  return 'infused coconut oil' if slug == 'infused-coconut-oil'
  return 'infused ghee' if slug == 'infused-ghee'
  return 'infused milk' if slug == 'infused-milk'
  return 'infused condensed milk' if slug == 'infused-condensed-milk'
  return 'infused honey' if slug == 'infused-honey'

  case category
  when 'keto', 'vegan'
    'infused coconut oil'
  when 'mocktails'
    'cannabis tincture'
  when 'drinks'
    sub_cat == 'alcoholic' ? 'cannabutter' : 'cannabis tincture'
  when 'essentials'
    'cannabutter'
  when 'desserts'
    %w[frozen confections].include?(sub_cat) ? 'infused coconut oil' : 'cannabutter'
  when 'lunch'
    %w[salad soup main_dish].include?(sub_cat) ? 'infused olive oil' : 'cannabutter'
  when 'snacks'
    sub_cat == 'dips' ? 'infused olive oil' : 'cannabutter'
  when 'international'
    sub_cat == 'brazilian_sweet' ? 'infused condensed milk' : 'infused olive oil'
  else
    'cannabutter'
  end
end

def cook_temp(category, sub_cat)
  case sub_cat
  when 'baked_goods', 'keto_baked', 'vegan_baked'
    '350F'
  when 'frozen'
    'freeze'
  when 'confections', 'puddings', 'keto_sweet', 'vegan_sweet'
    'stovetop'
  when 'pastries'
    '375F'
  when 'hot_drinks', 'keto_drink'
    'simmer'
  when 'cold_drinks', 'alcoholic', 'citrus', 'fruity', 'herbal_tea'
    'no_cook'
  when 'savory_snacks'
    '350F'
  when 'sweet_snacks', 'dips'
    'no_cook'
  when 'butter_oil'
    'simmer'
  when 'milk_cream'
    'simmer'
  when 'pasta_rice'
    'stovetop'
  when 'soup'
    'simmer'
  when 'salad'
    'no_cook'
  when 'sandwich_wrap'
    '400F'
  when 'main_dish'
    'stovetop'
  when 'keto_savory'
    '375F'
  when 'vegan_savory'
    'stovetop'
  when 'brazilian_sweet'
    'stovetop'
  when 'brazilian_savory'
    'stovetop'
  else
    'stovetop'
  end
end

def texture_type(category, sub_cat)
  case sub_cat
  when 'baked_goods', 'keto_baked', 'vegan_baked'
    'baked'
  when 'frozen'
    'frozen'
  when 'confections'
    'no_cook'
  when 'pastries'
    'fried'
  when 'puddings'
    'stovetop'
  when 'hot_drinks', 'cold_drinks', 'alcoholic', 'keto_drink',
       'citrus', 'fruity', 'herbal_tea'
    'no_cook'
  when 'savory_snacks'
    'baked'
  when 'sweet_snacks', 'dips'
    'no_cook'
  when 'butter_oil', 'milk_cream'
    'stovetop'
  when 'pasta_rice', 'main_dish', 'vegan_savory', 'brazilian_savory'
    'stovetop'
  when 'soup'
    'stovetop'
  when 'salad'
    'no_cook'
  when 'sandwich_wrap'
    'baked'
  when 'keto_sweet', 'vegan_sweet'
    'no_cook'
  when 'keto_savory'
    'baked'
  when 'brazilian_sweet'
    'stovetop'
  else
    'stovetop'
  end
end

def keywords_for(slug, name, category)
  # derive from name words + category
  words = name.downcase.gsub(/[^a-z0-9 ]/, '').split
  words -= %w[infused cannabis weed pot a the and of with]
  base = words.first(3).map(&:strip)
  base << 'cannabis edible'
  base << category
  base.uniq.first(5)
end

# ── Unique sentences per recipe ──────────────────────────────────────────────

UNIQUE_DATA = {
  # ── Desserts ───────────────────────────────────────────────────────────────
  'infused-banana-bread' => {
    intro: 'This moist banana bread uses overripe bananas to mask the herbal taste of cannabutter, making it one of the most beginner-friendly edibles you can bake.',
    dosing: 'Slice the loaf into 10 even pieces and label each with the per-slice dosage to avoid overconsumption.',
    storage: 'Wrap individual slices in parchment paper and freeze for up to 3 months; thaw at room temperature for 20 minutes before eating.',
    variation: 'Fold in dark chocolate chips and walnuts for a richer flavor that pairs especially well with the cannabis undertones.'
  },
  'infused-chocolate-truffles' => {
    intro: 'These hand-rolled chocolate truffles deliver precise single servings of cannabis in a rich ganache shell that melts on your tongue.',
    dosing: 'Use a small cookie scoop to portion the ganache so every truffle contains an identical amount of infused coconut oil.',
    storage: 'Layer truffles between sheets of wax paper in an airtight container and refrigerate for up to 2 weeks.',
    variation: 'Roll finished truffles in matcha powder, crushed freeze-dried raspberries, or toasted coconut for distinct flavor profiles.'
  },
  'pot-cookies' => {
    intro: 'Classic cannabis cookies with a chewy center and crisp edges are the quintessential homemade edible that never goes out of style.',
    dosing: 'Use a tablespoon-sized dough scoop and weigh each ball on a kitchen scale to guarantee uniform dosing across the batch.',
    storage: 'Store in a sealed jar at room temperature for up to 5 days, or freeze baked cookies in a zip-lock bag for 2 months.',
    variation: 'Swap chocolate chips for peanut butter chips and add a pinch of sea salt on top before baking for a sweet-salty twist.'
  },
  'pot-brownies' => {
    intro: 'Fudgy cannabis brownies are the most iconic edible of all time, combining deep cocoa flavor with the relaxing effects of THC.',
    dosing: 'Score the brownie slab into equal squares immediately after removing from the oven while the surface is still soft.',
    storage: 'Keep brownies in a sealed container at room temperature for 4 days, or individually wrap and freeze for up to 3 months.',
    variation: 'Swirl in a ribbon of cream cheese batter before baking to create a marbled cheesecake-brownie hybrid.'
  },
  'gummy-bears' => {
    intro: 'Homemade cannabis gummy bears let you control the exact milligram dose per piece while choosing your own fruit flavors and colors.',
    dosing: 'Calculate the total THC in your tincture, divide by the number of mold cavities, and pipette the mixture precisely into each mold.',
    storage: 'Toss finished gummies in a light coating of cornstarch and store in the fridge for up to 3 weeks to prevent sticking.',
    variation: 'Use tart cherry juice instead of flavored gelatin for a natural sour gummy with real fruit flavor and antioxidants.'
  },
  'gingerbread-cookies' => {
    intro: 'Warmly spiced gingerbread cookies infused with cannabutter are a festive holiday edible with bold molasses and ginger notes.',
    dosing: 'Roll dough to a uniform thickness and use the same cookie cutter size throughout so every cookie carries the same dose.',
    storage: 'Layer cooled cookies with parchment in a tin and store at room temperature for up to one week.',
    variation: 'Dip half of each cookie in white chocolate and sprinkle with crushed candy cane for a peppermint-gingerbread combo.'
  },
  'infused-honey' => {
    intro: 'Cannabis-infused honey is a versatile pantry staple you can stir into tea, drizzle over toast, or use as a sweetener in any recipe.',
    dosing: 'Measure honey by the teaspoon and note the mg per teaspoon on the jar label so you always know your intake.',
    storage: 'Keep in a dark glass jar at room temperature; infused honey remains potent and shelf-stable for up to 6 months.',
    variation: 'Steep a few sprigs of lavender or rosemary into the honey during infusion for an herbal flavor that complements the cannabis.'
  },
  'weed-rice-krispie-treats' => {
    intro: 'These nostalgic rice krispie treats get an adult upgrade with cannabutter melted directly into the marshmallow mixture for easy, no-bake preparation.',
    dosing: 'Press the mixture into a lined pan of known dimensions and cut into a grid of equal pieces for consistent dosing.',
    storage: 'Wrap each square individually in plastic wrap and store at room temperature for up to one week.',
    variation: 'Mix in a handful of mini M&Ms or drizzle melted dark chocolate over the top for extra indulgence.'
  },
  'cannabis-caramel-sauce' => {
    intro: 'Silky cannabis caramel sauce adds a sweet, buttery drizzle of THC to ice cream, fruit, or your favorite desserts.',
    dosing: 'Measure servings with a tablespoon and note the total batch potency divided by the number of tablespoons on the jar.',
    storage: 'Refrigerate in a squeeze bottle for up to 3 weeks; reheat gently in warm water before drizzling.',
    variation: 'Stir in a teaspoon of espresso powder while cooking for a coffee-caramel sauce that pairs beautifully with vanilla ice cream.'
  },
  'cannabis-cheesecake' => {
    intro: 'A creamy New York-style cheesecake infused with cannabutter in the crust and filling delivers an indulgent, long-lasting edible experience.',
    dosing: 'Slice the cheesecake into 12 equal portions using a hot knife for clean cuts and predictable per-slice potency.',
    storage: 'Cover with plastic wrap pressed directly on the surface and refrigerate for up to 5 days, or freeze slices for 2 months.',
    variation: 'Top with a layer of cannabis-infused fruit compote made from fresh berries for an extra dose and burst of color.'
  },
  'infused-tiramisu' => {
    intro: 'This Italian classic layers espresso-soaked ladyfingers with cannabis-infused mascarpone cream for a sophisticated no-bake dessert.',
    dosing: 'Divide the mascarpone mixture into the exact number of servings before assembling so each portion is dosed equally.',
    storage: 'Keep covered in the fridge for up to 3 days; tiramisu actually improves in flavor after 24 hours of chilling.',
    variation: 'Replace the espresso soak with matcha tea for a green tea tiramisu that offers a lighter, earthier flavor.'
  },
  'cannabis-apple-pie' => {
    intro: 'A golden, flaky-crusted apple pie made with cannabutter in the pastry delivers warm cinnamon-apple comfort with every slice.',
    dosing: 'Cut the pie into 8 equal slices using a pie marker pressed into the top crust before baking.',
    storage: 'Store loosely covered at room temperature for 2 days or refrigerate for up to 5 days; reheat slices in a 300F oven.',
    variation: 'Add a handful of fresh cranberries to the apple filling for tartness and a beautiful ruby-red color throughout.'
  },
  'infused-chocolate-lava-cake' => {
    intro: 'Individual chocolate lava cakes with a molten cannabis-infused center create a dramatic restaurant-quality dessert at home.',
    dosing: 'Prepare the batter in a single bowl and divide evenly among ramekins using a kitchen scale for identical per-cake dosing.',
    storage: 'Freeze unbaked filled ramekins for up to 1 month; bake directly from frozen, adding 2 extra minutes to the cook time.',
    variation: 'Add a small square of white chocolate in the center of each cake for a dual-chocolate molten core.'
  },
  'cannabis-lemon-bars' => {
    intro: 'Tangy lemon curd atop a buttery cannabis-infused shortbread crust makes these bars a bright, citrusy alternative to chocolate edibles.',
    dosing: 'Score the slab into uniform rectangles before the curd fully sets so each bar has a precise and equal dose.',
    storage: 'Refrigerate in a single layer in an airtight container for up to 5 days; dust with powdered sugar just before serving.',
    variation: 'Substitute lime juice and add a pinch of chili flakes for a spicy lime bar with a Mexican-inspired kick.'
  },
  'infused-carrot-cake' => {
    intro: 'Moist carrot cake studded with walnuts and raisins pairs beautifully with cannabis-infused cream cheese frosting for a layered edible.',
    dosing: 'Infuse only the frosting rather than the cake itself so you can control the dose by adjusting frosting thickness per slice.',
    storage: 'Refrigerate frosted cake for up to 4 days; bring to room temperature 30 minutes before serving for the best texture.',
    variation: 'Add crushed pineapple to the batter for extra moisture and a tropical twist on the classic carrot cake.'
  },
  'cannabis-coconut-macaroons' => {
    intro: 'Chewy coconut macaroons dipped in cannabis-infused chocolate are naturally gluten-free and deliver a satisfying tropical sweetness.',
    dosing: 'Use a small cookie scoop to form each macaroon and dip the base in a measured amount of infused chocolate.',
    storage: 'Store in the refrigerator for up to one week; the chocolate coating keeps them fresh and holds the cannabis infusion.',
    variation: 'Toast the shredded coconut before mixing for a deeper, nuttier flavor and golden-brown exterior.'
  },
  'infused-fudge' => {
    intro: 'Rich, dense cannabis fudge is a no-bake confection that packs a potent dose into a small, decadent square.',
    dosing: 'Pour into a parchment-lined pan of known size and cut into a precise grid so each piece has an equal dose.',
    storage: 'Refrigerate in an airtight container for up to 2 weeks or freeze for 3 months; fudge thaws quickly at room temperature.',
    variation: 'Layer peanut butter fudge on top of the chocolate fudge for a two-tone Reese\'s-inspired treat.'
  },
  'cannabis-blondies' => {
    intro: 'Cannabis blondies offer the chewy, butterscotch richness of a brownie without the cocoa, letting the cannabutter flavor shine through.',
    dosing: 'Bake in a square pan and slice into 16 uniform bars using a bench scraper for clean, equal portions.',
    storage: 'Store at room temperature in a sealed container for up to 5 days; blondies stay chewy longer than brownies.',
    variation: 'Add white chocolate chips and macadamia nuts for a tropical blondie with creamy, crunchy contrast.'
  },
  'infused-donut-holes' => {
    intro: 'Bite-sized cannabis donut holes are fried until golden and tossed in cinnamon sugar for a fun, shareable edible treat.',
    dosing: 'Pipe dough through a round tip and cut to equal lengths before frying so each donut hole is the same size and dose.',
    storage: 'Best eaten the same day; store leftovers in a paper bag at room temperature for up to 24 hours.',
    variation: 'Fill donut holes with cannabis-infused pastry cream using a piping bag for a Boston cream-style surprise center.'
  },
  'cannabis-peach-cobbler' => {
    intro: 'Warm cannabis peach cobbler with a golden biscuit topping celebrates summer fruit while delivering a comforting, slow-onset edible effect.',
    dosing: 'Use the same biscuit cutter for every topping round and distribute them evenly so each serving gets one biscuit and equal fruit.',
    storage: 'Cover and refrigerate for up to 3 days; reheat individual portions in a 325F oven for 10 minutes.',
    variation: 'Mix in fresh blueberries with the peaches for a peach-blueberry cobbler with a beautiful purple-gold color.'
  },
  'infused-baklava' => {
    intro: 'Layers of crispy phyllo, spiced nuts, and cannabis-infused honey syrup make this Mediterranean pastry a unique and aromatic edible.',
    dosing: 'Score the baklava into diamonds before baking and pour a measured amount of infused syrup so each piece absorbs equally.',
    storage: 'Cover loosely and store at room temperature for up to one week; do not refrigerate or the phyllo will become soggy.',
    variation: 'Use pistachios instead of walnuts and add a splash of rosewater to the syrup for a Persian-inspired version.'
  },
  'cannabis-chocolate-fondue' => {
    intro: 'Cannabis chocolate fondue turns any gathering into an interactive edible experience where guests dip fruit and treats into warm infused chocolate.',
    dosing: 'Calculate the total mg in the fondue pot and provide small dipping cups so each guest controls their own portion.',
    storage: 'Refrigerate leftover fondue in a jar for up to one week; reheat gently in a double boiler to restore the smooth texture.',
    variation: 'Use dark chocolate with chili powder and a pinch of cayenne for a Mexican hot chocolate-style fondue.'
  },
  'infused-strawberry-shortcake' => {
    intro: 'Flaky cannabis-infused biscuits topped with fresh strawberries and whipped cream create a light, elegant summer edible dessert.',
    dosing: 'Weigh each biscuit before baking to ensure equal cannabutter distribution and consistent dosing per serving.',
    storage: 'Store biscuits separately from the fruit and cream; assemble just before serving to keep everything fresh for up to 2 days.',
    variation: 'Macerate the strawberries with a splash of balsamic vinegar and black pepper to deepen their sweetness.'
  },
  'cannabis-panna-cotta' => {
    intro: 'Silky cannabis panna cotta is an Italian custard that showcases infused cream in a delicate, melt-in-your-mouth dessert.',
    dosing: 'Divide the warm cream mixture into individual ramekins using a measuring cup so each serving contains an identical dose.',
    storage: 'Cover each ramekin with plastic wrap and refrigerate for up to 4 days; unmold just before serving.',
    variation: 'Top with a thin layer of passion fruit coulis for a tropical contrast to the creamy vanilla base.'
  },
  'infused-churros' => {
    intro: 'Crispy on the outside and soft within, these cannabis-infused churros are fried to golden perfection and rolled in cinnamon sugar.',
    dosing: 'Pipe churro dough to the same length using a star tip and fry in batches of equal size for uniform dosing.',
    storage: 'Eat churros fresh for the best texture; if storing, keep in a paper bag and re-crisp in a 375F oven for 5 minutes.',
    variation: 'Serve with a side of cannabis chocolate dipping sauce for a double-dosed churro experience.'
  },
  'cannabis-crepes' => {
    intro: 'Thin, delicate cannabis crepes can be filled with sweet or savory fillings, making them a versatile vehicle for your infusion.',
    dosing: 'Use exactly 3 tablespoons of batter per crepe and swirl evenly so the cannabutter is distributed uniformly in each one.',
    storage: 'Stack cooled crepes between sheets of parchment and refrigerate for 2 days or freeze for up to 1 month.',
    variation: 'Fill with Nutella and sliced bananas for a classic Parisian street-food combination with an infused twist.'
  },
  'infused-mango-sorbet' => {
    intro: 'Dairy-free cannabis mango sorbet is a refreshing frozen edible with tropical sweetness and a smooth, scoopable texture.',
    dosing: 'Blend the infusion into the sorbet base before churning so it distributes evenly; use a standard scoop for serving.',
    storage: 'Store in a freezer-safe container with plastic wrap pressed on the surface to prevent ice crystals for up to 2 months.',
    variation: 'Add a squeeze of lime juice and a pinch of Tajin seasoning for a Mexican-inspired mango chile sorbet.'
  },
  'cannabis-cinnamon-rolls' => {
    intro: 'Soft, pillowy cinnamon rolls swirled with cannabis-infused butter and topped with cream cheese glaze are a decadent weekend brunch edible.',
    dosing: 'Roll the dough to a uniform rectangle and slice into equal portions with dental floss for perfectly even rolls.',
    storage: 'Cover tightly and store at room temperature for 2 days; reheat in a 300F oven for 5 minutes to restore softness.',
    variation: 'Replace the cinnamon filling with a cardamom-orange zest mixture for a Scandinavian-inspired flavor profile.'
  },
  'infused-coconut-pudding' => {
    intro: 'Creamy cannabis coconut pudding is a comforting, tropical dessert that sets up beautifully in individual cups for easy portion control.',
    dosing: 'Divide the warm pudding into serving cups using a ladle with a known volume so each cup gets the same dose.',
    storage: 'Cover cups with plastic wrap and refrigerate for up to 4 days; the pudding thickens further as it chills.',
    variation: 'Layer with toasted coconut flakes and a drizzle of mango puree for a tropical parfait presentation.'
  },

  # ── Drinks ─────────────────────────────────────────────────────────────────
  'infused-berry-smoothie' => {
    intro: 'A vibrant berry smoothie blended with cannabis tincture delivers a fruity, drinkable edible that kicks in smoothly.',
    dosing: 'Add your measured tincture dose to the blender last and blend briefly so it mixes evenly without degrading the cannabinoids.',
    storage: 'Drink immediately for the best texture; if needed, store in a sealed jar in the fridge for up to 4 hours.',
    variation: 'Add a scoop of protein powder and a handful of spinach for a post-workout recovery smoothie with benefits.'
  },
  'infused-lemonade' => {
    intro: 'Refreshing cannabis lemonade is a simple, crowd-pleasing summer drink that hides the herbal flavor behind bright citrus.',
    dosing: 'Mix the tincture into the full pitcher and stir thoroughly so each glass poured contains a consistent dose.',
    storage: 'Refrigerate in a sealed pitcher for up to 2 days; stir well before each serving as the tincture may settle.',
    variation: 'Muddle fresh mint and cucumber slices into each glass for a spa-style cannabis lemonade.'
  },
  'infused-whiskey' => {
    intro: 'Cannabis-infused whiskey combines two adult indulgences into one spirit that can be sipped neat or mixed into cocktails.',
    dosing: 'Start with a half-ounce pour since the combination of alcohol and THC intensifies both effects significantly.',
    storage: 'Store in a dark glass bottle away from sunlight; infused whiskey stays potent indefinitely at room temperature.',
    variation: 'Use a smoky bourbon and add a cinnamon stick during infusion for a warming, spiced winter spirit.'
  },
  'infused-chai' => {
    intro: 'Warming cannabis chai combines aromatic spices like cardamom, cinnamon, and ginger with infused milk for a soothing hot edible.',
    dosing: 'Prepare a single serving using one measured dose of infused milk per cup to maintain precise control over your intake.',
    storage: 'Brew fresh for the best flavor; leftover chai concentrate without milk can be refrigerated for up to 3 days.',
    variation: 'Add a shot of espresso for a dirty chai latte that combines caffeine alertness with the calming effects of THC.'
  },
  'infused-eggnog' => {
    intro: 'Rich, creamy cannabis eggnog is a festive holiday beverage that blends warm spices with infused cream for a seasonal treat.',
    dosing: 'Portion eggnog into 4-ounce servings since its richness and potency make smaller glasses more appropriate.',
    storage: 'Refrigerate in a sealed bottle for up to 3 days; shake well before pouring as the mixture separates.',
    variation: 'Sprinkle freshly grated nutmeg and a drizzle of caramel sauce on top for an elevated holiday presentation.'
  },
  'cannabis-hot-chocolate' => {
    intro: 'Velvety cannabis hot chocolate is the ultimate cold-weather edible, melting infused chocolate into steamed milk for a cozy cup.',
    dosing: 'Melt a measured amount of infused chocolate per mug and whisk thoroughly into the hot milk for even distribution.',
    storage: 'Best served fresh; leftover hot chocolate can be refrigerated and reheated gently the next day.',
    variation: 'Float a cannabis-infused marshmallow on top for double the dose and a playful presentation.'
  },
  'infused-cold-brew' => {
    intro: 'Smooth cannabis cold brew coffee steeps overnight with cannabis tincture for a caffeinated, uplifting edible drink.',
    dosing: 'Add the tincture to the finished cold brew concentrate rather than during steeping for more accurate dosing per glass.',
    storage: 'Store the infused concentrate in the fridge for up to 5 days; dilute with water or milk when serving.',
    variation: 'Add a splash of vanilla syrup and oat milk for a creamy, barista-style cannabis cold brew latte.'
  },

  # ── Snacks ─────────────────────────────────────────────────────────────────
  'firecrackers' => {
    intro: 'Firecrackers are the fastest cannabis edible you can make, requiring only graham crackers, peanut butter, and ground flower.',
    dosing: 'Spread a precisely weighed amount of decarbed cannabis on each cracker and seal tightly in foil before baking.',
    storage: 'Wrap each firecracker individually in foil and store at room temperature for up to 3 days.',
    variation: 'Use Nutella instead of peanut butter and add a sprinkle of sea salt for a sweet-salty chocolate version.'
  },
  'infused-guacamole' => {
    intro: 'Cannabis-infused guacamole blends ripe avocados with infused olive oil for a creamy, savory dip that pairs perfectly with chips.',
    dosing: 'Stir in a measured amount of infused olive oil and mix thoroughly so the dose is evenly spread throughout the bowl.',
    storage: 'Press plastic wrap directly onto the surface to prevent browning and refrigerate for up to 24 hours.',
    variation: 'Add diced fresh mango and a squeeze of lime for a tropical guacamole that balances richness with bright fruit.'
  },
  'infused-energy-bites' => {
    intro: 'No-bake cannabis energy bites packed with oats, nut butter, and honey provide a portable, protein-rich edible for on-the-go dosing.',
    dosing: 'Roll each bite using a tablespoon measure and weigh on a scale to guarantee identical dosing across the batch.',
    storage: 'Refrigerate in a sealed container for up to one week or freeze for 2 months; thaw for 5 minutes before eating.',
    variation: 'Add a scoop of cocoa powder and mini chocolate chips for a brownie batter-flavored energy bite.'
  },
  'infused-grilled-cheese' => {
    intro: 'A golden, crispy cannabis grilled cheese sandwich uses cannabutter on the bread for a savory, melty comfort food edible.',
    dosing: 'Spread a measured amount of cannabutter on each slice of bread before grilling so every sandwich is dosed consistently.',
    storage: 'Eat immediately for the best texture; grilled cheese does not store well but the cannabutter can be prepped in advance.',
    variation: 'Add sliced tomato and a drizzle of pesto between the cheese layers for a caprese-style grilled cheese.'
  },
  'trail-mix' => {
    intro: 'Cannabis trail mix combines infused honey-roasted nuts with dried fruit and chocolate for a portable, shelf-stable edible snack.',
    dosing: 'Measure the total infused component, mix evenly, and portion into labeled snack bags with the dose marked on each.',
    storage: 'Store in an airtight container at room temperature for up to 2 weeks; the nuts stay crunchy if kept sealed.',
    variation: 'Add coconut flakes and dried pineapple for a tropical trail mix variation with island-inspired flavors.'
  },
  'weed-infused-popcorn' => {
    intro: 'Cannabis-infused popcorn is a savory movie-night snack where melted cannabutter is drizzled over freshly popped kernels.',
    dosing: 'Melt a measured amount of cannabutter and toss with the popcorn in a large bowl for even coating and consistent dosing.',
    storage: 'Store in a paper bag or airtight container at room temperature for up to 2 days; re-crisp in a low oven if needed.',
    variation: 'Toss with nutritional yeast and garlic powder for a savory, cheese-flavored cannabis popcorn without dairy.'
  },
  'infused-hummus' => {
    intro: 'Smooth cannabis hummus blends chickpeas with infused olive oil and tahini for a protein-packed savory dip with a mellow onset.',
    dosing: 'Add the infused olive oil during blending and divide the finished hummus into measured serving cups for precise dosing.',
    storage: 'Refrigerate in a sealed container with a thin layer of olive oil on top for up to 5 days.',
    variation: 'Blend in roasted red peppers for a smoky, vibrant hummus with a sweeter flavor profile.'
  },
  'infused-granola' => {
    intro: 'Crunchy cannabis granola baked with infused coconut oil and honey is a versatile edible for topping yogurt or eating by the handful.',
    dosing: 'Spread granola evenly on a sheet pan, bake, and portion into small bags with the dose labeled on each.',
    storage: 'Store in an airtight jar at room temperature for up to 2 weeks; granola stays crunchiest when kept completely sealed.',
    variation: 'Add dried tart cherries and dark chocolate chunks after baking for a cherry-chocolate granola mix.'
  },

  # ── Essentials ─────────────────────────────────────────────────────────────
  'cannabutter' => {
    intro: 'Cannabutter is the foundational cannabis ingredient, infusing butter with decarbed flower through a slow, low-heat simmer.',
    dosing: 'Calculate the total THC from your starting flower, account for extraction efficiency around 80%, and label the jar with mg per tablespoon.',
    storage: 'Store in a sealed glass jar in the fridge for up to 2 months or freeze in silicone molds for up to 6 months.',
    variation: 'Use cultured European-style butter with higher fat content for a richer flavor and potentially better THC extraction.'
  },
  'infused-olive-oil' => {
    intro: 'Cannabis-infused olive oil is a heart-healthy, versatile base for savory edibles, dressings, and any recipe calling for cooking oil.',
    dosing: 'Note the total THC content and divide by the volume in tablespoons; label the bottle with mg per tablespoon.',
    storage: 'Store in a dark glass bottle in a cool cupboard for up to 3 months; olive oil resists rancidity better than butter.',
    variation: 'Infuse with fresh rosemary and garlic cloves alongside the cannabis for a flavored finishing oil.'
  },
  'infused-coconut-oil' => {
    intro: 'Cannabis-infused coconut oil has the highest saturated fat content of any cooking oil, making it exceptionally efficient at binding THC.',
    dosing: 'Pour into silicone ice cube molds for pre-measured tablespoon portions that are easy to pop out and use in recipes.',
    storage: 'Coconut oil is shelf-stable at room temperature for up to 3 months; refrigerate for longer storage up to 6 months.',
    variation: 'Use refined coconut oil for a neutral taste in recipes where you do not want coconut flavor.'
  },
  'infused-milk' => {
    intro: 'Cannabis-infused milk provides a liquid base for hot drinks, cereals, and baking that distributes THC evenly throughout dairy.',
    dosing: 'Use whole milk for the highest fat content and best extraction; measure servings in half-cup portions with labeled potency.',
    storage: 'Refrigerate and use within 5 days, the same shelf life as regular milk; shake before each use.',
    variation: 'Use heavy cream instead of milk for a more potent infusion with higher fat content and richer mouthfeel.'
  },
  'infused-condensed-milk' => {
    intro: 'Cannabis-infused condensed milk is a sweet, thick base ideal for fudge, tres leches cake, and Brazilian desserts.',
    dosing: 'The thick consistency makes it easy to measure by the tablespoon; note mg per tablespoon on the can or jar.',
    storage: 'Refrigerate in a sealed jar for up to 2 weeks; the high sugar content acts as a natural preservative.',
    variation: 'Simmer the sealed can in boiling water for 2 hours to create infused dulce de leche with a deeper caramel flavor.'
  },
  'infused-ghee' => {
    intro: 'Cannabis-infused ghee is clarified butter with the milk solids removed, offering a nutty, high-smoke-point fat perfect for cooking.',
    dosing: 'Ghee is denser than butter, so weigh your portions rather than using volume measurements for accurate dosing.',
    storage: 'Ghee is shelf-stable at room temperature for up to 3 months; its low moisture content prevents spoilage.',
    variation: 'Infuse with turmeric and black pepper during preparation for a golden ghee with anti-inflammatory properties.'
  },

  # ── Lunch ──────────────────────────────────────────────────────────────────
  'infused-pesto-pasta' => {
    intro: 'Cannabis pesto pasta coats al dente noodles in a vibrant basil-and-infused-olive-oil sauce that tastes remarkably close to the classic.',
    dosing: 'Mix the infused olive oil into the pesto at the end and toss with weighed pasta portions for consistent dosing per plate.',
    storage: 'Refrigerate dressed pasta for up to 2 days; toss with a splash of olive oil when reheating to restore moisture.',
    variation: 'Use sun-dried tomato pesto instead of traditional basil for a richer, tangier sauce with deeper umami notes.'
  },
  'infused-coconut-curry' => {
    intro: 'Fragrant cannabis coconut curry simmers vegetables and protein in an infused coconut milk sauce rich with spices and aromatics.',
    dosing: 'Stir the infused coconut oil into the curry at the end of cooking and serve over measured portions of rice.',
    storage: 'Refrigerate in airtight containers for up to 3 days; curry flavor actually improves overnight as the spices meld.',
    variation: 'Add a tablespoon of red curry paste and a squeeze of lime for a Thai-inspired version with more heat.'
  },
  'infused-spaghetti-bolognese' => {
    intro: 'A hearty cannabis bolognese sauce slow-simmered with infused olive oil clings to every strand of spaghetti for a satisfying dinner edible.',
    dosing: 'Add infused oil to the finished sauce and stir well; serve over weighed pasta portions to control the dose per plate.',
    storage: 'Freeze sauce in labeled portions for up to 2 months; thaw overnight in the fridge before reheating.',
    variation: 'Use half ground beef and half Italian sausage for a more complex, spiced bolognese.'
  },
  'cannabis-avocado-toast' => {
    intro: 'Cannabis avocado toast elevates the brunch staple by spreading mashed avocado mixed with infused olive oil on crusty sourdough.',
    dosing: 'Mix a measured amount of infused olive oil into the mashed avocado before spreading so each slice is dosed evenly.',
    storage: 'Prepare and eat immediately; avocado toast does not store well, but the infused oil can be prepped in advance.',
    variation: 'Top with a poached egg, everything bagel seasoning, and red pepper flakes for a loaded avocado toast.'
  },
  'cannabis-salad-dressing' => {
    intro: 'Cannabis salad dressing lets you dose any salad by whisking infused olive oil into a tangy vinaigrette base.',
    dosing: 'Calculate mg per tablespoon of dressing and use a measured pour for each salad serving.',
    storage: 'Shake well and refrigerate in a glass jar for up to one week; bring to room temperature before using if the oil solidifies.',
    variation: 'Blend in roasted garlic and Dijon mustard for a creamy cannabis Caesar-style dressing.'
  },
  'cannabis-shakshuka' => {
    intro: 'Cannabis shakshuka poaches eggs in a spiced tomato sauce enriched with infused olive oil for a one-pan brunch edible.',
    dosing: 'Drizzle the infused oil into the sauce before adding eggs, and serve each person one egg with an equal portion of sauce.',
    storage: 'Best eaten fresh; leftover sauce without eggs can be refrigerated for 2 days and reheated with fresh eggs.',
    variation: 'Crumble feta cheese and fresh herbs over the top just before serving for a Mediterranean finish.'
  },
  'infused-mushroom-risotto' => {
    intro: 'Creamy cannabis mushroom risotto stirs infused butter into Arborio rice at the final stage for a luxurious, earthy Italian dish.',
    dosing: 'Add a measured pat of cannabutter to each individual plate of risotto rather than the whole pot for precise per-serving dosing.',
    storage: 'Risotto is best fresh but can be refrigerated for 1 day; reheat with a splash of broth to restore creaminess.',
    variation: 'Use a mix of wild mushrooms like chanterelle and porcini for a more complex, woodsy flavor.'
  },
  'cannabis-thai-basil-chicken' => {
    intro: 'Cannabis Thai basil chicken is a quick stir-fry that combines wok-fired chicken with fresh Thai basil and infused oil.',
    dosing: 'Toss the infused oil in at the end of cooking over low heat to preserve potency, and divide into equal servings.',
    storage: 'Refrigerate for up to 2 days; reheat in a hot wok or skillet to maintain the stir-fry texture.',
    variation: 'Substitute ground pork for chicken and add extra Thai chilies for a spicier, street-food-style version.'
  },
  'infused-beef-tacos' => {
    intro: 'Seasoned cannabis beef tacos fold savory, infused-oil-cooked ground beef into warm tortillas with fresh toppings.',
    dosing: 'Cook the beef with a measured amount of infused oil and weigh the meat per taco for consistent dosing.',
    storage: 'Store cooked beef separately from tortillas and toppings in the fridge for up to 2 days; reheat meat before assembling.',
    variation: 'Use corn tortillas and top with pickled red onions and cotija cheese for authentic Mexican-style street tacos.'
  },
  'cannabis-chicken-caesar-salad' => {
    intro: 'Cannabis chicken Caesar salad dresses crisp romaine and grilled chicken with a creamy infused olive oil Caesar dressing.',
    dosing: 'The infusion is in the dressing, so measure exactly 2 tablespoons of dressing per serving for predictable dosing.',
    storage: 'Store dressing separately and toss with salad just before serving; dressed salad does not keep well.',
    variation: 'Use kale instead of romaine and add shaved Parmesan and toasted pine nuts for a heartier kale Caesar.'
  },
  'infused-cauliflower-fried-rice' => {
    intro: 'Cannabis cauliflower fried rice replaces grain with riced cauliflower stir-fried in infused oil for a low-carb savory edible.',
    dosing: 'Drizzle infused oil into the wok at the end of cooking and divide the fried rice into equal weighed portions.',
    storage: 'Refrigerate in airtight containers for up to 3 days; reheat in a hot skillet for the best texture.',
    variation: 'Add shrimp and a drizzle of toasted sesame oil for an Asian-inspired seafood fried rice.'
  },
  'cannabis-minestrone-soup' => {
    intro: 'Hearty cannabis minestrone simmers seasonal vegetables, beans, and pasta in a tomato broth finished with infused olive oil.',
    dosing: 'Stir infused oil into the finished soup and ladle into bowls using a measured scoop for consistent per-serving potency.',
    storage: 'Refrigerate for up to 4 days or freeze without pasta for up to 2 months; add cooked pasta when reheating.',
    variation: 'Stir in a spoonful of pesto on top of each bowl for a Genovese-style minestrone with herbal depth.'
  },
  'infused-pulled-pork-sliders' => {
    intro: 'Tender cannabis pulled pork sliders feature slow-cooked pork tossed in infused BBQ sauce and piled onto soft mini buns.',
    dosing: 'Mix the infused oil into the BBQ sauce and weigh the pulled pork per slider for equal dosing on each bun.',
    storage: 'Refrigerate pulled pork in sauce for up to 3 days; reheat gently and assemble sliders just before serving.',
    variation: 'Top with a tangy coleslaw and pickled jalapenos for a Southern-style slider with crunch and heat.'
  },
  'cannabis-greek-salad' => {
    intro: 'Cannabis Greek salad combines crisp cucumber, tomato, olives, and feta with a cannabis-infused olive oil and oregano dressing.',
    dosing: 'Whisk the infused oil into the dressing and drizzle a measured amount over each individual salad plate.',
    storage: 'Store undressed salad components in the fridge for up to 2 days; dress just before serving.',
    variation: 'Add marinated artichoke hearts and roasted red peppers for a more substantial Mediterranean salad.'
  },
  'infused-tomato-bisque' => {
    intro: 'Velvety cannabis tomato bisque blends roasted tomatoes with infused cream for a smooth, warming soup with a rich finish.',
    dosing: 'Stir infused cream into the blended soup and ladle into bowls using a measured cup for precise per-serving dosing.',
    storage: 'Refrigerate for up to 4 days or freeze for 2 months; reheat gently without boiling to preserve the cream.',
    variation: 'Roast the tomatoes with garlic and smoked paprika before blending for a smokier, deeper flavor profile.'
  },
  'cannabis-chicken-burrito-bowl' => {
    intro: 'A cannabis chicken burrito bowl layers seasoned chicken, rice, beans, and fresh toppings with infused oil for a complete meal edible.',
    dosing: 'Drizzle a measured amount of infused oil over each assembled bowl rather than cooking with it for more accurate dosing.',
    storage: 'Store components separately in the fridge for up to 3 days; assemble fresh bowls at mealtime.',
    variation: 'Use cauliflower rice instead of white rice and add pickled red onions for a lighter, tangier version.'
  },
  'infused-falafel-wrap' => {
    intro: 'Crispy cannabis falafel wraps bundle herbed chickpea patties with tahini sauce and fresh vegetables in warm pita bread.',
    dosing: 'Mix infused oil into the falafel mixture before forming and use a scoop to make uniform patties with equal doses.',
    storage: 'Store cooked falafel in the fridge for up to 3 days; reheat in a 375F oven to re-crisp the exterior.',
    variation: 'Add harissa paste to the tahini sauce for a smoky, spicy North African kick.'
  },
  'cannabis-butternut-squash-soup' => {
    intro: 'Silky cannabis butternut squash soup roasts the squash until caramelized, then blends it with infused cream for a naturally sweet bowl.',
    dosing: 'Stir infused cream into the blended soup and serve in measured ladles so each bowl has the same dose.',
    storage: 'Refrigerate for up to 4 days or freeze for up to 2 months; soup reheats beautifully without losing texture.',
    variation: 'Add a teaspoon of curry powder and a swirl of coconut cream for a Thai-inspired butternut squash soup.'
  },
  'infused-egg-fried-rice' => {
    intro: 'Cannabis egg fried rice is a quick weeknight edible that transforms day-old rice with infused oil, scrambled eggs, and soy sauce.',
    dosing: 'Add infused oil to the hot wok at the end and toss with the rice, then divide into equal portions by weight.',
    storage: 'Refrigerate for up to 2 days; reheat in a very hot skillet to restore the slightly crispy texture.',
    variation: 'Add diced Chinese sausage (lap cheong) and scallions for a Cantonese-style fried rice with sweet-savory depth.'
  },
  'cannabis-grilled-salmon' => {
    intro: 'Cannabis grilled salmon glazes fresh fillets with an infused olive oil and herb marinade before searing on a hot grill.',
    dosing: 'Brush each fillet with a measured tablespoon of infused oil marinade so every portion has a known, equal dose.',
    storage: 'Refrigerate cooked salmon for up to 2 days; serve cold on salads or reheat gently in a 275F oven.',
    variation: 'Glaze with a miso-ginger infused oil mixture for an umami-rich Asian-inspired salmon.'
  },
  'infused-caprese-salad' => {
    intro: 'Cannabis caprese salad drizzles infused olive oil over fresh mozzarella, ripe tomatoes, and fragrant basil for a simple Italian appetizer.',
    dosing: 'Drizzle a measured teaspoon of infused oil over each individual plate for clean, consistent dosing.',
    storage: 'Assemble and serve immediately; store the infused oil separately and slice ingredients fresh each time.',
    variation: 'Use burrata instead of mozzarella and add a drizzle of aged balsamic reduction for an elevated presentation.'
  },
  'cannabis-quesadilla' => {
    intro: 'Cannabis quesadillas crisp flour tortillas filled with melted cheese and a spread of cannabutter for a quick, satisfying edible meal.',
    dosing: 'Spread a measured amount of cannabutter on the inside of each tortilla before adding cheese and folding.',
    storage: 'Best served fresh and hot; store leftover filling separately and assemble new quesadillas when ready to eat.',
    variation: 'Add sauteed mushrooms, caramelized onions, and a drizzle of truffle oil for a gourmet quesadilla upgrade.'
  },
  'infused-pad-thai' => {
    intro: 'Cannabis pad Thai tosses rice noodles with a sweet-tangy tamarind sauce, finishing with infused oil for an authentic Thai street food edible.',
    dosing: 'Toss infused oil into the finished noodles off heat and serve in weighed portions for equal dosing per plate.',
    storage: 'Refrigerate for up to 2 days; reheat in a wok with a splash of water to loosen the noodles.',
    variation: 'Add crispy tofu and extra crushed peanuts for a heartier vegetarian pad Thai with more protein.'
  },
  'cannabis-pizza' => {
    intro: 'Cannabis pizza brushes the crust with infused olive oil before topping and baking for a shareable, crowd-friendly edible meal.',
    dosing: 'Brush a measured amount of infused oil on the dough and cut into equal slices so each piece has the same dose.',
    storage: 'Store leftover slices in the fridge for up to 2 days; reheat in a hot skillet for a crispy bottom crust.',
    variation: 'Top with fig jam, prosciutto, and arugula after baking for a gourmet pizza that showcases the infused oil base.'
  },
  'infused-lentil-dal' => {
    intro: 'Cannabis lentil dal simmers red lentils with aromatic spices and finishes with a tadka of infused ghee for a warming, protein-rich edible.',
    dosing: 'Drizzle the infused ghee tadka over individual bowls rather than the pot so each serving gets a measured dose.',
    storage: 'Refrigerate for up to 4 days or freeze for 2 months; dal thickens as it cools so add water when reheating.',
    variation: 'Add a can of diced tomatoes and a handful of fresh spinach for a more substantial and colorful dal.'
  },

  # ── Keto ───────────────────────────────────────────────────────────────────
  'infused-bulletproof-coffee' => {
    intro: 'Cannabis bulletproof coffee blends hot coffee with infused coconut oil and grass-fed butter for a keto-friendly, energizing edible drink.',
    dosing: 'Add a measured tablespoon of infused coconut oil to each cup and blend until frothy for even distribution.',
    storage: 'Drink immediately; the emulsion breaks down as it cools and the fats separate.',
    variation: 'Add a tablespoon of MCT oil and a dash of cinnamon for enhanced ketone production and warm spice flavor.'
  },
  'infused-coconut-fat-bombs' => {
    intro: 'Cannabis coconut fat bombs are bite-sized keto treats that pack infused coconut oil into a sweet, high-fat snack.',
    dosing: 'Pour into silicone candy molds using a measured pipette or small spoon so each fat bomb is identically dosed.',
    storage: 'Store in the freezer for up to 3 months; keep frozen as they melt quickly at room temperature.',
    variation: 'Add a layer of sugar-free dark chocolate on top of each fat bomb for a bounty bar-inspired treat.'
  },
  'infused-keto-peanut-butter-cookies' => {
    intro: 'Three-ingredient keto cannabis cookies use peanut butter, egg, and sweetener with infused coconut oil for a grain-free edible.',
    dosing: 'Scoop dough with a tablespoon measure and flatten with a fork for uniform cookies with consistent dosing.',
    storage: 'Store in an airtight container at room temperature for 3 days or refrigerate for up to one week.',
    variation: 'Use almond butter instead of peanut butter and press a sugar-free chocolate chip into each cookie before baking.'
  },
  'infused-keto-cheesecake-bites' => {
    intro: 'Mini keto cheesecake bites in a nut crust deliver creamy, low-carb cannabis portions that satisfy sweet cravings without sugar.',
    dosing: 'Divide the filling evenly among muffin tin cups using a measured scoop so each bite contains the same dose.',
    storage: 'Refrigerate for up to 5 days or freeze for 2 months; thaw in the fridge for 1 hour before eating.',
    variation: 'Swirl sugar-free raspberry puree into the top of each cheesecake bite before chilling for a fruity marbled finish.'
  },
  'infused-keto-chocolate-avocado-mousse' => {
    intro: 'Keto cannabis chocolate avocado mousse blends ripe avocado with cocoa and infused coconut oil for a silky, dairy-free dessert.',
    dosing: 'Blend all ingredients together and divide into ramekins using a measuring cup for exact per-serving potency.',
    storage: 'Refrigerate covered for up to 2 days; the avocado may oxidize slightly but a stir restores the color.',
    variation: 'Top with whipped coconut cream and cacao nibs for a crunchy, indulgent garnish.'
  },
  'infused-keto-cauliflower-pizza-crust' => {
    intro: 'A cannabis-infused cauliflower pizza crust gives keto dieters a low-carb base for all their favorite pizza toppings.',
    dosing: 'Mix infused oil into the cauliflower dough before pressing into shape; cut the baked pizza into equal slices.',
    storage: 'Freeze unbaked crusts between parchment sheets for up to 2 months; bake directly from frozen.',
    variation: 'Add Italian herbs and garlic powder to the crust mixture for a more flavorful, seasoned base.'
  },
  'infused-chocolate-bark' => {
    intro: 'Cannabis chocolate bark is a simple no-bake keto treat that spreads melted infused chocolate thin and tops it with nuts and seeds.',
    dosing: 'Spread chocolate to a uniform thickness on a parchment-lined sheet and score into equal pieces before it fully sets.',
    storage: 'Store in the fridge for up to 2 weeks; the bark snaps cleanly along scored lines when cold.',
    variation: 'Use white chocolate with freeze-dried strawberries and crushed pistachios for a colorful, fruity bark.'
  },
  'cannabis-keto-bacon-bites' => {
    intro: 'Crispy cannabis keto bacon bites wrap bacon around cream cheese filling infused with coconut oil for a savory, high-fat appetizer.',
    dosing: 'Fill each bacon cup with a measured teaspoon of infused cream cheese mixture for uniform dosing.',
    storage: 'Refrigerate for up to 3 days; reheat in a 350F oven for 5 minutes to re-crisp the bacon.',
    variation: 'Add diced jalapeno to the cream cheese filling for a spicy, popper-style bacon bite.'
  },
  'infused-keto-chicken-wings' => {
    intro: 'Cannabis keto chicken wings are baked until crispy and tossed in an infused butter hot sauce for a finger-licking edible.',
    dosing: 'Toss wings in a measured amount of infused butter sauce and count the number of wings per serving for dosing accuracy.',
    storage: 'Refrigerate for up to 3 days; reheat in a 400F oven to maintain crispiness rather than microwaving.',
    variation: 'Use a garlic parmesan infused butter sauce instead of hot sauce for a milder, savory wing option.'
  },
  'cannabis-keto-deviled-eggs' => {
    intro: 'Cannabis keto deviled eggs pipe a creamy, infused yolk filling back into halved egg whites for an elegant low-carb appetizer.',
    dosing: 'Mix infused oil into the yolk filling and pipe an equal amount into each egg half for consistent per-piece dosing.',
    storage: 'Refrigerate on a covered plate for up to 2 days; garnish with paprika just before serving.',
    variation: 'Top each egg with a small piece of smoked salmon and a sprig of dill for a luxurious appetizer.'
  },
  'infused-keto-stuffed-mushrooms' => {
    intro: 'Cannabis keto stuffed mushrooms fill cremini caps with an infused cream cheese and sausage mixture baked until bubbly and golden.',
    dosing: 'Use a measured teaspoon of filling per mushroom cap so each piece delivers the same dose.',
    storage: 'Refrigerate assembled mushrooms for up to 2 days before baking, or store baked leftovers for 3 days.',
    variation: 'Use crabmeat instead of sausage and add Old Bay seasoning for a seafood-stuffed mushroom variation.'
  },
  'cannabis-keto-beef-chili' => {
    intro: 'Hearty cannabis keto beef chili slow-cooks ground beef with tomatoes and spices, finished with a drizzle of infused oil for a no-bean, low-carb bowl.',
    dosing: 'Stir infused oil into the finished chili and serve with a ladle of known volume for consistent per-bowl dosing.',
    storage: 'Refrigerate for up to 4 days or freeze for up to 2 months; chili flavor deepens overnight.',
    variation: 'Add diced poblano peppers and a dollop of sour cream for a smoky, creamy chili topping.'
  },
  'infused-keto-zucchini-chips' => {
    intro: 'Thin-sliced cannabis keto zucchini chips are baked until crispy after being brushed with infused olive oil and seasoned with salt.',
    dosing: 'Brush each chip with a uniform coating of infused oil and count chips per serving for accurate dosing.',
    storage: 'Store in a paper bag at room temperature for up to 2 days; they lose crispness in sealed containers.',
    variation: 'Sprinkle with smoked paprika and garlic powder before baking for a BBQ-flavored chip.'
  },
  'cannabis-keto-waffles' => {
    intro: 'Fluffy cannabis keto waffles use almond flour and infused coconut oil to create a grain-free breakfast that crisps beautifully in the iron.',
    dosing: 'Pour a measured amount of batter per waffle using a ladle so each waffle is the same size and dose.',
    storage: 'Freeze cooked waffles on a sheet pan then transfer to a zip-lock bag; toast from frozen for a quick breakfast.',
    variation: 'Add a teaspoon of vanilla extract and top with sugar-free maple syrup and fresh berries.'
  },
  'infused-keto-salmon-patties' => {
    intro: 'Cannabis keto salmon patties bind flaked salmon with egg and almond flour, pan-fried in infused oil for a protein-rich edible.',
    dosing: 'Form patties to the same weight using a kitchen scale and cook each in a measured amount of infused oil.',
    storage: 'Refrigerate cooked patties for up to 3 days; reheat in a skillet to maintain the crispy exterior.',
    variation: 'Add lemon zest and fresh dill to the patty mixture and serve with a sugar-free tartar sauce.'
  },
  'cannabis-keto-spinach-dip' => {
    intro: 'Warm cannabis keto spinach dip blends cream cheese, spinach, and infused oil into a bubbly, savory appetizer for low-carb dipping.',
    dosing: 'Stir infused oil into the dip and serve with measured portions using a small ladle or serving spoon.',
    storage: 'Refrigerate for up to 4 days; reheat in the oven at 350F until bubbly.',
    variation: 'Add artichoke hearts and sun-dried tomatoes for a Mediterranean-inspired spinach artichoke dip.'
  },
  'infused-keto-almond-flour-cake' => {
    intro: 'A moist cannabis keto almond flour cake has a tender crumb and nutty flavor that rivals wheat-based cakes without the carbs.',
    dosing: 'Bake in a round pan and cut into 12 even slices; the infused coconut oil distributes evenly through the dense batter.',
    storage: 'Refrigerate for up to 5 days; the almond flour keeps the cake moist longer than traditional flour would.',
    variation: 'Add lemon zest and a sugar-free lemon glaze for a bright, citrusy keto cake.'
  },

  # ── Vegan ──────────────────────────────────────────────────────────────────
  'cannabis-vegan-brownies' => {
    intro: 'Dense, fudgy cannabis vegan brownies use flax eggs and infused coconut oil to deliver a plant-based edible indistinguishable from the original.',
    dosing: 'Cut the brownie slab into equal squares with a bench scraper and label each piece with its dose for safe sharing.',
    storage: 'Store in an airtight container at room temperature for 3 days or freeze individually wrapped for 2 months.',
    variation: 'Add a swirl of almond butter on top before baking for a nutty, marbled vegan brownie.'
  },
  'infused-vegan-cheese-sauce' => {
    intro: 'Creamy cannabis vegan cheese sauce blends soaked cashews with nutritional yeast and infused coconut oil for a dairy-free nacho topping.',
    dosing: 'Blend a measured amount of infused oil into the sauce and pour measured portions over individual servings.',
    storage: 'Refrigerate in a jar for up to 5 days; reheat gently and add water to thin if needed.',
    variation: 'Add chipotle peppers in adobo sauce for a smoky, spicy vegan queso dip.'
  },
  'cannabis-lentil-soup' => {
    intro: 'Hearty cannabis lentil soup simmers lentils with aromatic vegetables and finishes with a drizzle of infused olive oil for a nourishing vegan edible.',
    dosing: 'Stir infused oil into the finished soup and ladle into bowls using a measured scoop for per-serving dosing.',
    storage: 'Refrigerate for up to 5 days or freeze for up to 3 months; lentil soup freezes exceptionally well.',
    variation: 'Add a squeeze of lemon and a handful of fresh parsley before serving for brightness and color.'
  },
  'infused-vegan-pancakes' => {
    intro: 'Fluffy cannabis vegan pancakes use plant milk and infused coconut oil in a simple batter that cooks up golden and tender.',
    dosing: 'Pour a measured quarter-cup of batter per pancake so each one has an identical dose of infused coconut oil.',
    storage: 'Freeze cooked pancakes in a single layer then stack with parchment; reheat in a toaster for a quick breakfast.',
    variation: 'Fold fresh blueberries into the batter and top with pure maple syrup for a classic blueberry pancake stack.'
  },
  'cannabis-sweet-potato-curry' => {
    intro: 'Cannabis sweet potato curry combines tender roasted sweet potato cubes with a rich coconut-infused sauce and fragrant spices.',
    dosing: 'Stir infused coconut oil into the curry at the end and serve over measured portions of rice or flatbread.',
    storage: 'Refrigerate for up to 4 days; the sweet potato holds its shape well when reheated.',
    variation: 'Add chickpeas and a handful of spinach in the last 5 minutes of cooking for added protein and greens.'
  },
  'infused-jackfruit-tacos' => {
    intro: 'Cannabis jackfruit tacos shred young green jackfruit into a pulled-pork texture and season it with infused oil and smoky spices.',
    dosing: 'Mix infused oil into the jackfruit filling while cooking and weigh the filling per taco for consistent dosing.',
    storage: 'Store the seasoned jackfruit filling in the fridge for up to 3 days; reheat and assemble tacos fresh.',
    variation: 'Top with a pineapple-jalapeno slaw for a sweet-heat contrast that brightens the smoky jackfruit.'
  },
  'cannabis-vegan-chocolate-mousse' => {
    intro: 'Silky cannabis vegan chocolate mousse whips aquafaba with melted dark chocolate and infused coconut oil into an airy, dairy-free dessert.',
    dosing: 'Fold infused oil into the chocolate base before adding the whipped aquafaba, then divide into individual cups.',
    storage: 'Refrigerate covered for up to 3 days; the mousse firms up slightly but maintains its silky texture.',
    variation: 'Top with coconut whipped cream and a pinch of flaky sea salt for an elegant, salted chocolate finish.'
  },
  'infused-vegan-mac-and-cheese' => {
    intro: 'Cannabis vegan mac and cheese coats elbow pasta in a cashew-based cheese sauce enriched with infused coconut oil for a comforting plant-based edible.',
    dosing: 'Blend infused oil into the cheese sauce and measure pasta portions by weight so each bowl gets the same dose.',
    storage: 'Refrigerate for up to 3 days; add a splash of plant milk when reheating to restore the creamy sauce.',
    variation: 'Top with herbed breadcrumbs and bake at 375F for 15 minutes for a crispy-topped vegan mac.'
  },
  'cannabis-coconut-milk-ice-cream' => {
    intro: 'Cannabis coconut milk ice cream churns full-fat coconut milk with infused coconut oil into a creamy, dairy-free frozen edible.',
    dosing: 'Mix infused oil into the ice cream base before churning for even distribution; use a standard scoop for serving.',
    storage: 'Store in a freezer-safe container for up to 2 months; let soften at room temperature for 5 minutes before scooping.',
    variation: 'Swirl in a ribbon of salted caramel sauce and chopped roasted peanuts for a vegan sundae experience.'
  },
  'infused-chickpea-stew' => {
    intro: 'Cannabis chickpea stew simmers chickpeas with tomatoes and warm spices, finished with infused olive oil for a hearty vegan edible.',
    dosing: 'Drizzle infused oil into each bowl individually using a measured spoon rather than mixing into the whole pot.',
    storage: 'Refrigerate for up to 5 days or freeze for 3 months; stew actually improves in flavor the next day.',
    variation: 'Add preserved lemon and green olives for a Moroccan-inspired chickpea tagine variation.'
  },
  'cannabis-vegan-protein-balls' => {
    intro: 'Cannabis vegan protein balls combine plant protein powder, oats, and infused coconut oil into no-bake bites for post-workout recovery.',
    dosing: 'Roll each ball using a tablespoon measure and weigh on a scale for uniform dosing across the batch.',
    storage: 'Refrigerate for up to one week or freeze for up to 2 months; they hold together well straight from the freezer.',
    variation: 'Roll in shredded coconut or cacao powder for different coatings that add flavor and visual variety.'
  },
  'infused-vegan-pesto-zoodles' => {
    intro: 'Cannabis vegan pesto zoodles toss spiralized zucchini in a dairy-free basil pesto made with infused olive oil and pine nuts.',
    dosing: 'Mix a measured amount of infused oil into the pesto and toss with weighed portions of zoodles for accurate dosing.',
    storage: 'Eat immediately; zucchini noodles release water quickly and do not store well once dressed.',
    variation: 'Add cherry tomatoes and marinated artichoke hearts for a Mediterranean zoodle bowl with more substance.'
  },
  'cannabis-black-bean-soup' => {
    intro: 'Smoky cannabis black bean soup blends simmered black beans with cumin and infused olive oil for a thick, protein-rich vegan edible.',
    dosing: 'Stir infused oil into the finished soup and serve in measured ladles; partially blending creates a thicker, more even consistency.',
    storage: 'Refrigerate for up to 5 days or freeze for up to 3 months; the soup thickens as it cools so add water when reheating.',
    variation: 'Top each bowl with diced avocado, a dollop of vegan sour cream, and a sprinkle of smoked paprika.'
  },
  'infused-vegan-banana-ice-cream' => {
    intro: 'One-ingredient cannabis banana ice cream blends frozen bananas with infused coconut oil for the easiest vegan frozen edible imaginable.',
    dosing: 'Add a measured amount of infused oil per banana used and blend until smooth for per-scoop dosing consistency.',
    storage: 'Serve immediately for soft-serve texture, or freeze for 1 hour for a firmer scoop; best consumed the same day.',
    variation: 'Blend in a tablespoon of peanut butter and a handful of chocolate chips for a chunky monkey flavor.'
  },
  'cannabis-roasted-vegetable-medley' => {
    intro: 'Cannabis roasted vegetable medley tosses seasonal vegetables in infused olive oil and roasts them until caramelized and tender.',
    dosing: 'Toss vegetables with a measured amount of infused oil and divide the roasted medley into equal portions by weight.',
    storage: 'Refrigerate for up to 4 days; roasted vegetables reheat well in a 400F oven for 10 minutes.',
    variation: 'Add a balsamic glaze drizzle and crumbled vegan feta after roasting for a sweet-tangy finish.'
  },

  # ── Mocktails ──────────────────────────────────────────────────────────────
  'cannabis-sparkling-lemonade' => {
    intro: 'Bubbly cannabis sparkling lemonade combines fresh lemon juice and sparkling water with cannabis tincture for a festive, alcohol-free refresher.',
    dosing: 'Add tincture to each glass individually rather than the pitcher so every guest gets their preferred dose.',
    storage: 'Mix fresh for each serving; sparkling water goes flat within an hour if stored.',
    variation: 'Add a splash of elderflower syrup and garnish with a sprig of thyme for a botanical sparkling lemonade.'
  },
  'infused-virgin-mojito' => {
    intro: 'An infused virgin mojito muddles fresh mint and lime with cannabis tincture and sparkling water for a crisp, herbaceous mocktail.',
    dosing: 'Add a measured dropper of tincture to each glass after muddling the mint and lime.',
    storage: 'Prepare and serve immediately; the mint wilts and the sparkling water flattens if left standing.',
    variation: 'Muddle fresh watermelon chunks along with the mint for a watermelon virgin mojito with natural pink color.'
  },
  'cannabis-cucumber-mint-cooler' => {
    intro: 'A cannabis cucumber mint cooler blends cool cucumber with fresh mint and a dose of tincture for a spa-like, calming mocktail.',
    dosing: 'Stir tincture into each individual glass and garnish with a cucumber ribbon for an elegant per-serving dose.',
    storage: 'Refrigerate the cucumber-mint base without tincture for up to 24 hours; add tincture and ice when serving.',
    variation: 'Add a few slices of fresh jalapeno for a spicy cucumber cooler with a surprising kick.'
  },
  'infused-watermelon-slush' => {
    intro: 'Frozen cannabis watermelon slush blends fresh watermelon and ice with tincture for a frosty, hydrating summer mocktail.',
    dosing: 'Add tincture to the blender with the watermelon and ice so it distributes evenly; pour into equal-sized glasses.',
    storage: 'Serve immediately; the slush melts quickly and loses its frozen texture within 15 minutes.',
    variation: 'Add a handful of frozen strawberries for a strawberry-watermelon slush with deeper berry flavor.'
  },
  'cannabis-lavender-lemonade' => {
    intro: 'Cannabis lavender lemonade steeps dried lavender into a simple syrup and combines it with lemon juice and tincture for a floral, soothing drink.',
    dosing: 'Mix tincture into the completed lavender lemonade and stir well; pour measured glasses for consistent dosing.',
    storage: 'Refrigerate the lavender lemonade base for up to 3 days; add tincture to individual servings.',
    variation: 'Add a splash of butterfly pea flower tea for a color-changing lemonade that turns purple with the lemon acid.'
  },
  'infused-tropical-punch' => {
    intro: 'Cannabis tropical punch combines pineapple, orange, and passion fruit juices with tincture for a vibrant party-ready mocktail.',
    dosing: 'Stir tincture into the full punch bowl and use a ladle of known volume so each cup poured has an equal dose.',
    storage: 'Refrigerate the punch base for up to 2 days; stir before serving as the tincture may settle.',
    variation: 'Float scoops of mango sorbet in the punch bowl for a creamy, tropical float effect.'
  },
  'cannabis-strawberry-basil-smash' => {
    intro: 'A cannabis strawberry basil smash muddles ripe strawberries with fresh basil and tincture for a sweet, herbaceous mocktail with depth.',
    dosing: 'Add a measured dose of tincture to each glass after muddling the fruit and basil.',
    storage: 'Serve immediately; muddled strawberries oxidize and lose their vibrant color within an hour.',
    variation: 'Add a splash of balsamic vinegar for an Italian-inspired strawberry basil drink with savory undertones.'
  },
  'infused-hibiscus-tea' => {
    intro: 'Ruby-red infused hibiscus tea steeps dried hibiscus flowers with cannabis tincture for a tart, antioxidant-rich hot or iced drink.',
    dosing: 'Add tincture to each cup individually after steeping so the heat does not degrade the cannabinoids.',
    storage: 'Refrigerate the brewed hibiscus tea for up to 4 days; add tincture to each serving when ready to drink.',
    variation: 'Steep with a cinnamon stick and whole cloves for a warm, mulled hibiscus tea perfect for cold evenings.'
  },
  'cannabis-peach-iced-tea' => {
    intro: 'Cannabis peach iced tea infuses black tea with fresh peach puree and a dose of tincture for a sweet Southern-style mocktail.',
    dosing: 'Stir tincture into the chilled tea and pour measured glasses; the peach puree helps mask any herbal tincture flavor.',
    storage: 'Refrigerate for up to 2 days; shake or stir before serving as the peach puree settles.',
    variation: 'Add a sprig of rosemary and a drizzle of honey for an herbal peach tea with floral aromatics.'
  },
  'infused-mango-lassi' => {
    intro: 'A thick, creamy infused mango lassi blends ripe mango with yogurt and cannabis tincture for a traditional Indian drink with a twist.',
    dosing: 'Blend tincture into each individual lassi serving so you can control the dose per glass precisely.',
    storage: 'Drink immediately or refrigerate for up to 4 hours; the yogurt separates if left too long.',
    variation: 'Add a pinch of cardamom and saffron threads for an authentic, fragrant lassi with golden hue.'
  },
  'cannabis-rose-lemonade' => {
    intro: 'Delicate cannabis rose lemonade blends rosewater and fresh lemon juice with tincture for a beautifully pink, floral mocktail.',
    dosing: 'Add tincture to each glass and stir; the rosewater flavor pairs well with and masks the herbal tincture notes.',
    storage: 'Refrigerate the rose lemonade base for up to 3 days; add tincture to individual servings when ready.',
    variation: 'Garnish with edible rose petals and a sugar rim for a stunning presentation at special occasions.'
  },
  'infused-pineapple-ginger-fizz' => {
    intro: 'Zesty infused pineapple ginger fizz combines fresh pineapple juice with ginger beer and tincture for a bubbly, spicy-sweet mocktail.',
    dosing: 'Add tincture to each glass before topping with ginger beer; stir gently to avoid losing carbonation.',
    storage: 'Serve immediately; the ginger beer loses its fizz quickly once opened and mixed.',
    variation: 'Add a splash of turmeric juice and a pinch of black pepper for an anti-inflammatory golden fizz.'
  },
  'cannabis-cranberry-spritzer' => {
    intro: 'Tart cannabis cranberry spritzer mixes unsweetened cranberry juice with sparkling water and tincture for a festive, low-sugar mocktail.',
    dosing: 'Add tincture to each glass individually and top with sparkling water for a measured, effervescent dose.',
    storage: 'Store the cranberry juice base in the fridge for up to 5 days; add sparkling water and tincture when serving.',
    variation: 'Add a splash of pomegranate juice and garnish with fresh rosemary for a holiday-themed spritzer.'
  },
  'infused-matcha-cooler' => {
    intro: 'An infused matcha cooler whisks ceremonial-grade matcha with iced oat milk and cannabis tincture for an earthy, energizing green drink.',
    dosing: 'Whisk tincture into the matcha paste before adding milk so it integrates fully into the drink.',
    storage: 'Serve immediately; matcha settles and the drink loses its vibrant green color if stored.',
    variation: 'Add a splash of vanilla syrup and serve over ice for a matcha vanilla iced latte with cannabis.'
  },
  'cannabis-passion-fruit-lemonade' => {
    intro: 'Tropical cannabis passion fruit lemonade combines tangy passion fruit pulp with fresh lemon juice and tincture for an exotic, sunny mocktail.',
    dosing: 'Mix tincture into the lemonade base and stir well; strain the passion fruit seeds or leave them for texture.',
    storage: 'Refrigerate for up to 2 days; stir before serving as the passion fruit pulp separates.',
    variation: 'Add coconut water instead of still water for a tropical island-inspired passion fruit coconut lemonade.'
  },
  'infused-cherry-limeade' => {
    intro: 'Bold infused cherry limeade combines tart cherry juice with fresh lime and cannabis tincture for a retro-diner-style mocktail.',
    dosing: 'Add tincture to each glass with measured cherry juice and lime for consistent per-serving dosing.',
    storage: 'Refrigerate the cherry-lime base for up to 3 days; add tincture and ice when serving.',
    variation: 'Use frozen dark sweet cherries muddled in the glass for a fresh, chunky cherry limeade with more fruit.'
  },
  'cannabis-mint-green-tea' => {
    intro: 'Cannabis mint green tea steeps loose-leaf green tea with fresh mint and adds tincture for a light, refreshing hot or iced edible drink.',
    dosing: 'Steep tea first, then add tincture to each cup after cooling slightly to preserve cannabinoid potency.',
    storage: 'Refrigerate brewed tea for up to 2 days; add tincture to individual servings when ready to drink.',
    variation: 'Add a teaspoon of honey and a squeeze of lemon for a Moroccan-inspired sweetened mint tea.'
  },
  'infused-blueberry-lemonade' => {
    intro: 'Vibrant infused blueberry lemonade blends fresh blueberries with lemon juice and tincture for a stunning purple mocktail packed with antioxidants.',
    dosing: 'Blend tincture into the blueberry puree before straining and mixing with lemonade for even distribution.',
    storage: 'Refrigerate for up to 2 days; shake before serving as the blueberry puree settles to the bottom.',
    variation: 'Add a splash of coconut cream for a creamy blueberry lemonade smoothie with a tropical twist.'
  },
  'cannabis-ginger-turmeric-tonic' => {
    intro: 'A warming cannabis ginger turmeric tonic combines anti-inflammatory ginger and turmeric with tincture, honey, and lemon for a wellness-focused mocktail.',
    dosing: 'Mix tincture into each cup after the tonic cools to drinking temperature to preserve the cannabinoids.',
    storage: 'Refrigerate the ginger-turmeric base for up to 5 days; reheat gently and add tincture when serving.',
    variation: 'Add a pinch of cayenne pepper and apple cider vinegar for a fire cider-inspired immune-boosting tonic.'
  },
  'infused-coconut-lime-agua-fresca' => {
    intro: 'A light infused coconut lime agua fresca blends coconut water with fresh lime juice and tincture for a hydrating, tropical mocktail.',
    dosing: 'Add tincture to the full pitcher and stir thoroughly; pour equal-sized glasses for consistent dosing.',
    storage: 'Refrigerate for up to 2 days; the coconut water keeps the drink fresh and naturally sweet.',
    variation: 'Add muddled fresh mint and a splash of pineapple juice for a pina colada-inspired agua fresca.'
  },

  # ── International ──────────────────────────────────────────────────────────
  'cannabis-feijoada' => {
    intro: 'Cannabis feijoada is a rich Brazilian black bean and pork stew simmered with infused olive oil, served over rice with traditional sides.',
    dosing: 'Stir infused oil into the stew at the end of cooking and serve with a measured ladle for per-bowl dosing.',
    storage: 'Refrigerate for up to 4 days or freeze for 2 months; feijoada tastes even better the next day.',
    variation: 'Add sliced Portuguese linguica sausage and smoked pork ribs for a more traditional, smokier stew.'
  },
  'infused-brigadeiro' => {
    intro: 'Infused brigadeiros are beloved Brazilian chocolate truffles made from cannabis-infused condensed milk, cocoa, and butter rolled into bite-sized balls.',
    dosing: 'Roll each brigadeiro to the same size using a teaspoon measure so every piece has an identical dose.',
    storage: 'Store in petit four cups in the fridge for up to one week; they firm up perfectly when chilled.',
    variation: 'Use white chocolate and coconut instead of cocoa for a beijinho-brigadeiro hybrid called prestígio.'
  },
  'cannabis-pacoca' => {
    intro: 'Cannabis pacoca is a crumbly Brazilian peanut candy made with ground roasted peanuts, sugar, and infused condensed milk pressed into sweet cylinders.',
    dosing: 'Press the mixture into a mold and cut into equal pieces by weight for uniform dosing per candy.',
    storage: 'Store in an airtight container at room temperature for up to 2 weeks; the candy stays crumbly and fresh.',
    variation: 'Dip the bottom of each pacoca in melted dark chocolate for a chocolate-peanut combination.'
  },
  'infused-coxinha' => {
    intro: 'Infused coxinhas are teardrop-shaped Brazilian croquettes filled with seasoned shredded chicken and fried in a dough made with infused oil.',
    dosing: 'Shape each coxinha to the same size using a kitchen scale and fry them in batches for consistent dosing.',
    storage: 'Freeze uncooked coxinhas on a sheet pan and transfer to a bag; fry directly from frozen when ready to serve.',
    variation: 'Fill with catupiry cheese alongside the chicken for the classic coxinha de catupiry variation.'
  },
  'cannabis-pao-de-queijo' => {
    intro: 'Cannabis pao de queijo are chewy Brazilian cheese bread balls made with tapioca flour and infused olive oil for a naturally gluten-free edible.',
    dosing: 'Scoop dough with a tablespoon measure for uniform balls; each one should weigh the same for equal dosing.',
    storage: 'Freeze unbaked dough balls on a parchment-lined sheet; bake directly from frozen, adding 3 minutes to the cook time.',
    variation: 'Add grated Parmesan and a pinch of calabresa pepper flakes for a spicy, extra-cheesy version.'
  },
  'infused-acai-bowl' => {
    intro: 'An infused acai bowl blends frozen acai pulp with cannabis tincture and banana into a thick, purple smoothie base topped with granola and fruit.',
    dosing: 'Add tincture to the blender with the acai and banana so the dose distributes evenly through the bowl.',
    storage: 'Serve immediately; acai bowls melt and lose their thick texture within 20 minutes.',
    variation: 'Top with toasted coconut flakes, cacao nibs, and a drizzle of honey for a classic Brazilian acai experience.'
  },
  'cannabis-moqueca' => {
    intro: 'Cannabis moqueca is a fragrant Brazilian fish stew simmered in coconut milk, tomatoes, and infused olive oil with dendê-style flavors.',
    dosing: 'Stir infused oil into the stew at the end and ladle equal portions of fish and broth into each bowl.',
    storage: 'Refrigerate for up to 2 days; reheat gently to avoid overcooking the fish.',
    variation: 'Use shrimp instead of white fish and add a splash of palm oil (dendê) for the most authentic Bahian flavor.'
  },
  'infused-tapioca-crepe' => {
    intro: 'An infused tapioca crepe cooks hydrated tapioca flour on a dry griddle and fills it with savory or sweet fillings drizzled with infused oil.',
    dosing: 'Drizzle a measured teaspoon of infused coconut oil inside each crepe before adding fillings for precise dosing.',
    storage: 'Eat immediately; tapioca crepes become rubbery when they cool and do not store or reheat well.',
    variation: 'Fill with coconut flakes and infused condensed milk for a classic coco com leite condensado tapioca.'
  },
  'cannabis-beijinho' => {
    intro: 'Cannabis beijinhos are delicate Brazilian coconut truffles made from infused condensed milk and shredded coconut, a sweeter cousin to the brigadeiro.',
    dosing: 'Roll each beijinho to the same size using a teaspoon measure and top with a single clove for the traditional presentation.',
    storage: 'Refrigerate in petit four cups for up to one week; they hold their shape best when kept cold.',
    variation: 'Roll in toasted coconut flakes instead of regular for a nuttier, more deeply flavored coating.'
  },
  'infused-empadao' => {
    intro: 'Infused empadao is a large Brazilian savory pie with a flaky cannabis-infused crust filled with chicken, olives, and hearts of palm.',
    dosing: 'The infused oil is in the crust, so cut the pie into equal slices for consistent per-portion dosing.',
    storage: 'Refrigerate for up to 3 days; reheat slices in a 350F oven for 10 minutes to re-crisp the crust.',
    variation: 'Make individual empadinhas (small tartlets) instead of one large pie for built-in portion control and easier dosing.'
  }
}

# ── Build enrichment data ────────────────────────────────────────────────────

enrichment = {}

recipes_data['categories'].each do |cat|
  category_slug = cat['slug']

  cat['recipes'].each do |recipe|
    slug = recipe['slug']
    sub_cat = find_sub_category(slug, category_slug)
    prep, cook, total = time_defaults(category_slug, sub_cat)
    nutr = nutrition_defaults(category_slug, sub_cat)
    fat = base_fat(category_slug, sub_cat, slug)
    temp = cook_temp(category_slug, sub_cat)
    tex = texture_type(category_slug, sub_cat)
    kw = keywords_for(slug, recipe['name'], category_slug)

    unique = UNIQUE_DATA[slug] || {
      intro: "A delicious cannabis-infused #{recipe['name'].downcase} that delivers consistent effects.",
      dosing: 'Start with a low dose and wait at least 90 minutes before consuming more.',
      storage: 'Store in an airtight container in the refrigerator for up to one week.',
      variation: 'Experiment with different flavor combinations to find your preferred version.'
    }

    enrichment[slug] = {
      'prepTime'         => prep,
      'cookTime'         => cook,
      'totalTime'        => total,
      'keywords'         => kw,
      'nutrition'        => nutr,
      'base_fat'         => fat,
      'cook_temp'        => temp,
      'texture_type'     => tex,
      'sub_category'     => sub_cat,
      'intro_unique'     => unique[:intro],
      'dosing_unique'    => unique[:dosing],
      'storage_unique'   => unique[:storage],
      'variation_unique' => unique[:variation]
    }
  end
end

File.write(OUTPUT, JSON.pretty_generate(enrichment))
puts "Wrote #{enrichment.size} recipes to #{OUTPUT}"
