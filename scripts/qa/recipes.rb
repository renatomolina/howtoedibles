# Layer 1 of the recipe review: pass/fail per recipe and language on 8 criteria.
# Usage: ruby scripts/qa/recipes.rb <site root> [--json out.json]
# Checks that read the English source (dose, template-vs-dish, coherence, serving unit) are reported once per recipe
# with lang "all": the translations reuse the same numbers, template choice and step structure (parity checks that).
require "csv"
require_relative "recipe_page"

root = ARGV.fetch(0)
json_out = ARGV[ARGV.index("--json") + 1] if ARGV.include?("--json")
site = Site.new(root)
SLUGS = site.recipes.map { |r| r["slug"] }
BASE_SLUGS = %w[cannabutter infused-coconut-oil infused-olive-oil infused-ghee infused-milk infused-honey cannabis-sugar cannabis-flour cannabis-tincture].freeze
FAILS = []
def fail!(check, slug, lang, src, msg); FAILS << { check: check, slug: slug, lang: lang, src: src, msg: msg[0, 260] }; end

EN = SLUGS.to_h { |s| [s, site.page(s, "en")] }
PAGES = LANGS.to_h { |l| [l, SLUGS.to_h { |s| [s, l == "en" ? EN[s] : site.page(s, l)] }] }

# ───────── 1. dose (logic from tmp/wayfinder/dose_scan.rb) ─────────
COOK = 0.8
THC = File.read(File.join(root, "scripts/build_redesign.rb"))[/DEFAULT_THC\s*=\s*([\d.]+)/, 1].to_f
BASES = [ # [pattern, grams of flower per cup of the site base, label]
  [/cannabutter|canna-?butter|cannabis[- ]infused butter|cannabis butter|infused butter/i, 6.4, "cannabutter"],
  [/(?:infused|cannabis[- ]infused|cannabis) (?:extra[- ]virgin )?olive oil/i, 2.0 / 1.27, "olive oil"],
  [/infused coconut oil|cannabis[- ]infused coconut oil|cannabis coconut oil/i, 6.4, "coconut oil"],
  [/canna-?oil|cannabis oil|infused oil|cannabis[- ]infused oil|(?:cannabis|infused|cannabis[- ]infused) (?:vegetable|cooking|sesame|avocado|canola|neutral) oil/i, 6.4, "oil with no site base (coconut-oil ratio)"],
  [/infused ghee|cannabis ghee/i, 3.5, "ghee"],
  [/(?:infused|cannabis[- ]infused|cannabis) (?:whole )?(?:milk|heavy cream|cream|coconut milk|half-and-half)/i, 0.237, "milk/cream"],
  [/cannabis sugar|infused sugar/i, 6.4, "sugar"],
  [/cannabis flour|infused flour/i, 6.4, "flour"],
  [/tincture/i, 14.0, "tincture"],
  [/infused honey|cannabis honey|cannabis-infused honey/i, 3.5 / 1.4, "honey"],
  [/(?:infused|cannabis) condensed milk/i, 0.4 / 1.3, "condensed milk (1 tbsp cannabutter per can)"],
  [/(?:cannabis|infused)[\w -]{0,20}?(?:syrup|whiskey|vodka|rum|tequila|wine)/i, nil, "no site base"],
].freeze
FRAC = { "½" => 0.5, "¼" => 0.25, "¾" => 0.75, "⅓" => 1.0 / 3, "⅔" => 2.0 / 3, "⅛" => 0.125 }.freeze
UNIT = "cups?|tablespoons?|tbsp|teaspoons?|tsp|ml|g\\b|grams?|oz|ounces?|sticks?"
NUM = "\\d+(?:\\.\\d+)?(?:\\s*[½¼¾⅓⅔⅛])?|[½¼¾⅓⅔⅛]|\\d+\\s+\\d+/\\d+|\\d+/\\d+"
def num(s)
  s = s.strip
  return s.split(/\s+/).sum { |p| num(p) } if s.include?(" ")
  return s.split("/").map(&:to_f).then { |a, b| a / b } if s.include?("/")
  s.chars.sum { |c| FRAC[c] || 0 } + s.to_f
end
def cups_before(t, re)
  pos = t =~ re or return nil
  m = t[0...pos].scan(/(?:(#{NUM})\s*-\s*)?(#{NUM})\s*(#{UNIT})/io).last or return nil
  n = num(m[1])
  case m[2].downcase
  when /\Acup/ then n
  when /\At(able)?(bsp|blespoon)/, /tablespoon/ then n / 16.0
  when /\At(ea)?(sp|spoon)/, /teaspoon/ then n / 48.0
  when "ml" then n / 236.6
  when "g", /\Agram/ then n / 227.0
  when "oz", /\Aounce/ then n / 8.0
  when /\Astick/ then n / 2.0
  end
end
FLOWER_LINE = /\d+(?:\.\d+)?\s*(grams?|g)\s+(of\s+)?(ground\s+|decarb\w*\s+)*(cannabis|weed|flower|marijuana|bud)\b/i
SLUGS.each do |slug|
  p = EN[slug]
  shown = 10 * p[:g] * THC * COOK / p[:n]
  fail!("1c dose shown > 15", slug, "all", "recipes.json suggested_*", format("shown %.1f mg > 15", shown)) if shown.round(1) > 15.0
  next if BASE_SLUGS.include?(slug)
  direct = p[:ings].any? { |l| l.match?(FLOWER_LINE) && !l.match?(/infused|oil|butter/i) }
  infused = p[:ings].filter_map { |l| (b = BASES.find { |re, _| l.match?(re) }) && [l, b, cups_before(l, b[0])] }
  next if direct
  if infused.empty?
    fail!("1d dose unknown", slug, "all", "ingredients", "no cannabis ingredient recognised: " + p[:ings].first(3).join(" | "))
    next
  end
  unk = infused.select { |_, (_, ratio), cups| ratio.nil? || cups.nil? }
  unless unk.empty?
    fail!("1d dose unknown", slug, "all", "ingredients", "no site base recipe for: " + unk.map(&:first).join(" | "))
    next
  end
  grams = infused.sum { |_, (_, ratio), cups| ratio * cups }
  real = 10 * grams * THC * COOK / p[:n]
  next if (real / shown - 1).abs <= 0.05
  fail!(real > shown ? (real > 15.05 ? "1a dose OVER shown, real > 15 mg" : "1e dose a bit over shown, still <= 15 mg") : "1b dose under shown", slug, "all", "ingredients", format("real %.1f mg vs shown %.1f mg (%.2fx) | %s", real, shown, real / shown, infused.map { |l, b, _| "#{l} [#{b[2]}]" }.join(" | ")))
end

# ───────── 2. the template fits the dish ─────────
OVEN = /\b(preheat|oven|bake[sd]?|baking|roast(ed|ing)?|broil)\b/i
FRY = /\b(deep[- ]?fr(y|ied)|fry|fried|frying)\b/i
HEAT = /\b(saucepan|skillet|pan|simmer|boil|stovetop|heat|melt|saut[eé]|cook|warm|toast|steam|grill|microwave|double boiler)\b/i
COLDDRINK = /\b(ice|iced|chill(ed)?|cold|blend(er)?|frozen|shake)\b/i
HOTDRINK = /\b(steep|simmer|boil(ing)?|hot|warm|mug|heat)\b/i
SLUGS.each do |slug|
  p = EN[slug]
  next if BASE_SLUGS.include?(slug) && false
  steps = p[:steps].join(" ")
  oven = steps.match?(OVEN) && !steps.match?(/\bno[- ]bake\b/i) || steps.match?(/\b(bake|oven)\b/i)
  fried = steps.match?(FRY)
  hot = p[:cat] == "Drinks" && steps.match?(/\b(steep|simmer|boil|serve (hot|warm)|mug|warm(ed)? milk|heat (the )?(milk|water))\b/i) && !steps.match?(/\b(over ice|ice cubes|chill|blend)\b/i)
  cold = p[:cat] == "Drinks" && !hot
  # a step that heats the infused ingredient itself by frying
  infused_fry = p[:steps].any? { |x| x.match?(FRY) && x.match?(/cannab|infused|tincture/i) }
  neg = /(instead of|rather than|avoid|not|never|no|nothing is|no need to|without|skip|don't|do not)\s+(?:\w+\s+){0,3}/i
  p[:tmpl].each do |k, lines|
    lines.each_with_index do |t, i|
      src = "template #{p[:cat]}/#{p[:sub]}.#{k}[#{i}]"
      c = ->(why) { fail!("2 template contradicts", slug, "all", src, "#{why}: #{t}") }
      off = ->(why) { fail!("2 template off-topic", slug, "all", src, "#{why}: #{t}") }
      t2 = t.gsub(/\bno[- ]bake\b/i, "").gsub(/\b(than|unlike|compared to|compared with) (dense |traditional |regular )?baked goods/i, "").gsub(/#{neg.source}(bak\w*|oven)/i, "")
      other = t.match?(/\b(like|such as) [a-z ]+(,| and| or) /i) || t.match?(/pao de queijo|strudel|kuchen/i) && !p[:name].match?(/p[aã]o de queijo|strudel|kuchen/i)
      question = other || k == "faq" && t.match?(/\A(Can|Could|Should|Is|How do I|What if)\b/)
      if t2.match?(/\b(bak(e|es|ed|ing)|oven)\b/i) && !oven
        question ? off.("FAQ about baking, the recipe never bakes") : c.("says the dish is baked / uses the oven, the recipe never bakes")
      end
      c.("warm/steeped-drink text on a cold drink") if cold && t.gsub(/warm (days|weather|afternoons?)/i, "").match?(/\b(steep(ed|ing)?|warm|hot water|calming infused tea|herbal tea)\b/i) && !question
      c.("cold-drink text on a hot drink") if hot && t.match?(/\b(over ice|iced|chilled|ice cubes)\b/i) && !question
      off.("hard-candy text, the recipe isn't a candy") if t.match?(/\b(hard cand(y|ies)|candy thermometer|soft ball|hard crack)\b/i) && !steps.match?(/\b(candy|thermometer|lollipop|caramel|toffee|fudge)\b/i)
      c.("pastry-dough text on a fried dough") if t.match?(/\b(laminat\w*|flaky)\b/i) && fried && !oven
      c.("infuse-from-flower text on a recipe that uses a ready base") if t.match?(/\binfuse (decarb\w* )?(cannabis )?flower|decarboxylated cannabis flower\b/i) && !BASE_SLUGS.include?(slug) && !p[:ings].any? { |l| l.match?(FLOWER_LINE) }
      c.("the %{cook_temp} slot puts a non-oven value after 'bake at'") if t.match?(/\bbak\w* (beautifully )?at (stovetop|no|low heat|medium|simmer|freeze|steam)/i)
      c.("says don't fry with the cannabis fat, the recipe fries with it") if infused_fry && t.match?(/(avoid|don't|do not|wastes?|destroy\w*|never)[^.]{0,70}\b(fry|frying|deep[- ]fr\w*)\b/i)
    end
  end
  fat = p[:enrich]["base_fat"].to_s
  infl = p[:ings].grep(/cannab|infused|tincture|weed|canna/i).join(" ")
  key = fat[/butter|coconut|olive|ghee|milk|cream|honey|sugar|syrup|tincture|whiskey|sesame|vegetable|flower|condensed|oil/i].to_s.downcase
  key = "butter|cannabutter" if key == "butter"
  unless key.empty? || infl.match?(/#{key}/i) || BASE_SLUGS.include?(slug)
    fail!("2 template contradicts", slug, "all", "enrichment base_fat", "templates name '#{fat}' but the recipe's infused ingredient is: #{infl[0, 120]}")
  end
end

# ───────── 3. food safety: perishable dishes never kept out of the fridge > 2 h ─────────
ROOM = { "en" => /room temperature|room temp\b|on the counter|countertop|cool,? dry place|in the pantry/i,
         "pt" => /temperatura ambiente|local fresco e seco|despensa/i, "es" => /temperatura ambiente|lugar fresco y seco|despensa/i,
         "de" => /Raumtemperatur|Zimmertemperatur|kühlen,? trockenen Ort|Speisekammer/i, "zh" => /室温|常温|阴凉干燥|阴凉处/ }.freeze
FRIDGE = { "en" => /refrigerat|fridge/i, "pt" => /geladeira|refrigera/i, "es" => /refrigera|nevera/i, "de" => /Kühlschrank|gekühlt|kühl lagern/i, "zh" => /冰箱|冷藏/ }.freeze
FREEZE = { "en" => /freez|frozen/i, "pt" => /congel/i, "es" => /congel/i, "de" => /gefrier|einfrier|tiefkühl/i, "zh" => /冷冻|冰冻/ }.freeze
WORDNUM = { "a" => 1, "an" => 1, "one" => 1, "two" => 2, "three" => 3, "four" => 4, "five" => 5, "six" => 6, "seven" => 7, "ten" => 10, "several" => 3, "few" => 3,
            "um" => 1, "uma" => 1, "dois" => 2, "duas" => 2, "três" => 3, "quatro" => 4, "cinco" => 5, "un" => 1, "una" => 1, "dos" => 2, "tres" => 3, "cuatro" => 4,
            "ein" => 1, "eine" => 1, "einen" => 1, "zwei" => 2, "drei" => 3, "vier" => 4, "fünf" => 5, "一" => 1, "两" => 2, "二" => 2, "三" => 3, "四" => 4, "五" => 5, "六" => 6, "七" => 7 }.freeze
UNITDAYS = [[/\A(hours?|horas?|Stunden?|小时|h)\z/i, 1.0 / 24], [/\A(days?|dias?|días?|Tagen?|Tage|天|日)\z/i, 1], [/\A(weeks?|semanas?|Wochen?|周|星期)\z/i, 7], [/\A(months?|meses|mes|Monaten?|Monate|个月|月)\z/i, 30]].freeze
DUR = /(\d+(?:[.,]\d+)?|[一两二三四五六七]|\b(?:a|an|one|two|three|four|five|six|seven|ten|several|few|um|uma|dois|duas|três|quatro|cinco|un|una|dos|tres|cuatro|ein|eine|einen|zwei|drei|vier|fünf)\b)(?:\s*(?:-|–|to|a|bis|至|到|or|ou|o)\s*(\d+|[一两二三四五六七]|\b(?:two|three|four|five|six|seven|dois|duas|três|quatro|dos|tres|cuatro|zwei|drei|vier)\b))?\s*(hours?|horas?|Stunden?|小时|days?|dias?|días?|Tagen?|Tage|天|weeks?|semanas?|Wochen?|个?星期|周|months?|meses|Monaten?|Monate|个月)/i
def to_n(x); x.nil? ? nil : (WORDNUM[x.downcase] || x.tr(",", ".")).to_f; end
def durations(s)
  s.scan(DUR).map do |a, b, u|
    f = UNITDAYS.find { |re, _| u.sub(/\A个/, "").match?(re) }&.last || 1
    lo = to_n(a) * f
    hi = (to_n(b) || to_n(a)) * f
    [lo.round(2), hi.round(2)]
  end
end
def clauses(text); text.split(/(?<=[.;!?。；！？])\s*|,\s*(?=or |and |ou |o |y |oder |und )|，|或/); end
# storage claims per page: [kind, [lo,hi] days, source, clause]
def storage_claims(site, p, lang)
  out = []
  site.blocks(p).each do |src, text|
    next if src.start_with?("ingredient")
  clauses(text).each do |c|
    next if c.match?(/before serving|antes de servir|vor dem Servieren|食用前|bring (it )?to room|let .* come to room|cool(ed)? (completely |slightly )?to room|esfri\w+ .*temperatura ambiente|enfri\w+ .*temperatura ambiente|auf Raumtemperatur abk|冷却至室温|deixe .* temperatura ambiente|soften|amolecer|llegue a temperatura/i) && durations(c).all? { |_, hi| hi < 1 }
    # each duration belongs to the nearest storage word before it (else the first one after it)
    marks = { room: ROOM[lang], fridge: FRIDGE[lang], freezer: FREEZE[lang] }.flat_map { |k, re| c.to_enum(:scan, re).map { [Regexp.last_match.begin(0), k] } }.sort
    next if marks.empty?
    c.to_enum(:scan, DUR).map { Regexp.last_match }.each do |m|
      kind = (marks.select { |pos, _| pos < m.begin(0) }.last || marks.first)[1]
      out << [kind, durations(m[0]).first, src, c]
    end
  end
end
  out
end
MEATFISH = /\b(chicken|beef|pork|bacon|ham|sausages?|bratwurst|turkey|lamb|steak|meat|fish|salmon|tuna|cod|tilapia|shrimp|prawns?|clams?|seafood|chorizo|anchov\w*|carnitas|currywurst)\b/i
FRESHDAIRY = /\b(cream cheese|mascarpone|ricotta|sour cream|yogh?urt|whipped cream|whipping cream|heavy cream|cream|milk|half-and-half|buttermilk|custard|cheese|paneer|feta|mozzarella|parmesan|cheddar|gruy[eè]re|kefir)\b/i
EGG = /\beggs?\b|\begg yolks?\b/i
FILLING = /\b(caramel sauce|fondue|ganache|buttercream|french toast|cheese|cream cheese|mascarpone|ricotta|whipped cream|whipping cream|heavy cream|custard|pastry cream|frosting|cheesecake|meringue|key lime|pumpkin pie|pecan pie|cream pie|tres leches|creme|crème|pudding)\b/i
SLUGS.each do |slug|
  en = EN[slug]
  ings = en[:ings].reject { |l| l.match?(/\b(butter|ghee|oil)\b/i) && !l.match?(FRESHDAIRY) }.join(" ") # butter/ghee/oil alone keep at room temp
  ings_all = en[:ings].join(" ") + " " + en[:name]
  perish = []
  perish << "meat/fish" if ings_all.match?(MEATFISH) && !ings_all.match?(/fish sauce|chicken broth only/i)
  perish << "dairy" if ings.gsub(/milk chocolate|chocolate milk|coconut (milk|cream)|almond milk|oat milk|soy milk|plant milk|vegan \w+|cocoa butter|peanut butter|cream of tartar|sweetened condensed milk|condensed milk|ice cream/i, "").match?(FRESHDAIRY)
  perish << "egg" if ings_all.match?(EGG)
  next if perish.empty?
  steps = en[:steps].join(" ")
  baked = steps.match?(/\b(bake|oven)\b/i)
  # USDA FoodKeeper: fully baked, low-moisture goods (cookies, brownies, quick breads, plain cakes) keep at room temperature;
  # anything with a fresh-dairy filling/frosting, custard, meat or fish does not.
  exempt = (baked || steps.match?(FRY) && en[:cat] != "Lunch") && !perish.include?("meat/fish") && !(ings_all + " " + en[:name]).match?(FILLING)
  LANGS.each do |lang|
    p = PAGES[lang][slug]
    storage_claims(site, p, lang).select { |k, (lo, hi), _, _| k == :room && hi > 2.0 / 24 }.each do |_, (lo, hi), src, c|
      sev = exempt ? "3x food safety: baked/fried dough, USDA ok" : "3 food safety"
      fail!(sev, slug, lang, src, "#{perish.join("+")}: room temperature #{hi >= 1 ? "#{hi.round(1)} d" : "#{(hi * 24).round} h"} | #{c}")
    end
  end
end

# ───────── 4. internal coherence ─────────
def iso_min(s); md = /PT(?:(\d+)H)?(?:(\d+)M)?/.match(s.to_s); md ? md[1].to_i * 60 + md[2].to_i : 0; end
STEPDUR = /(\d+(?:\.\d+)?|[½¼¾]|an?|one|two|three|four|five|six)(?:\s*(?:-|–|to)\s*(\d+(?:\.\d+)?))?\s*(?:more\s+|additional\s+|full\s+)?(minutes?|mins?|hours?|hrs?)\b/i
SLUGS.each do |slug|
  p = EN[slug]
  e = p[:enrich]
  total = iso_min(e["totalTime"]).nonzero? || iso_min(e["prepTime"]) + iso_min(e["cookTime"])
  fail!("4a total time", slug, "all", "enrichment totalTime", "totalTime #{e["totalTime"]} isn't PTxHyM: the page shows #{total} min") if e["totalTime"].to_s.match?(/\dD|P\d+W/) || (e["totalTime"] && !e["totalTime"].start_with?("PT"))
  sum = 0
  hits = []
  p[:steps].each do |s|
    next if s.match?(/\b(store|keeps?|lasts?|up to \d+ (days|weeks)|will keep)\b/i) && !s.match?(/\b(bake|cook|simmer|chill|freeze|refrigerate) (for|until)/i)
    s.scan(/(.{0,30}?)(?<![\d.,])#{STEPDUR}/io).each do |pre, a, _b, u|
      next if pre.match?(/every|up to|within|wait(ing)?( at least)?|before (eating|consuming|having)|after eating|take|onset|effects?|last|another|per|each side.*per|repeat/i)
      v = to_n(a) || 0
      v = { "½" => 0.5, "¼" => 0.25, "¾" => 0.75 }[a] || v
      m = u.start_with?("h") ? v * 60 : v
      sum += m
      hits << "#{a} #{u}"
    end
    if s.match?(/\bovernight\b/i)
      sum += 480
      hits << "overnight"
    end
  end
  fail!("4a total time", slug, "all", "enrichment totalTime", "page total #{total} min < #{sum.round} min stated in the steps (#{hits.join(", ")})") if sum > total + 5
  # temperatures
  steps = p[:steps].join(" ")
  stepF = steps.scan(/(\d{3})\s*°?\s*F\b/i).flatten.map(&:to_i).uniq
  ovenF = p[:steps].select { |s| s.match?(/oven|bake|preheat|roast|broil/i) }.join(" ").scan(/(\d{3})\s*°?\s*F\b/i).flatten.map(&:to_i).uniq
  ct = e["cook_temp"].to_s
  ctF = ct.scan(/(\d{3})\s*°?\s*F?/).flatten.map(&:to_i).select { |x| x >= 150 && x < 600 }
  if !ovenF.empty? && !ctF.empty? && (ovenF & ctF).empty?
    fail!("4b temperature", slug, "all", "enrichment cook_temp", "templates say #{ct}, the steps bake at #{ovenF.join("/")}°F")
  elsif !ovenF.empty? && ctF.empty? && p[:tmpl].values.flatten.any? { |t| t.include?(ct) && !ct.empty? }
    fail!("4b temperature", slug, "all", "enrichment cook_temp", "templates say '#{ct}', the steps bake at #{ovenF.join("/")}°F")
  end
  p[:tmpl].each do |k, lines|
    lines.each_with_index do |t, i|
      t.scan(/(?:above|over|exceed\w*|higher than|beyond)\s+(\d{3})\s*°?\s*F/i).flatten.map(&:to_i).each do |lim|
        hot = ovenF.select { |x| x > lim }
        fail!("4b temperature", slug, "all", "template #{p[:cat]}/#{p[:sub]}.#{k}[#{i}]", "says >#{lim}°F degrades THC, the recipe bakes at #{hot.join("/")}°F: #{t}") unless hot.empty?
      end
    end
  end
  # servings
  n = p[:n].round
  texts = p[:steps] + [p[:own]["dosing_unique"]]
  counts = []
  texts.each do |s|
    s.scan(/\b(?:cut|slice|divide|portion|shape|roll|form|scoop|pour|split|pipe|makes?|yields?)\b[^.]{0,60}?\binto\s+(?:about\s+)?(\d+)(?:\s*(?:-|–|to)\s*(\d+))?\s+(?!minutes|hours|inch|cm|mm|°|horizontal|layers?|shells?|halves|thirds|rounds|strips|logs|ropes|sheets|portions of dough|batches)(\w+)/i) { counts << [$1.to_i, ($2 || $1).to_i, $3, s] }
    s.scan(/\b(?:makes?|yields?|serves)\s+(?:about\s+)?(\d+)(?:\s*(?:-|–|to)\s*(\d+))?/i) { counts << [$1.to_i, ($2 || $1).to_i, "", s] }
  end
  counts.reject! { |lo, _, w, _| w.to_s.match?(/\A(halves|thirds|quarters|pieces?)\z/i) && lo <= 4 && false }
  bad = counts.reject { |lo, hi, _, _| (lo..hi).cover?(n) }
  bad.each { |lo, hi, w, s| fail!("4c servings", slug, "all", "steps/dosing_unique", "page doses for #{n} servings, the text says #{lo}#{hi != lo ? "-#{hi}" : ""} #{w}: #{s}") }
  # every ingredient used in a step
  stext = (p[:steps].join(" ") + " " + p[:own].values.join(" ")).downcase
  covers = { /dry ingredients/ => /flour|salt|baking|cocoa|sugar|cinnamon|spice|powder|soda|oats|almond flour|starch|yeast|nutmeg|ginger|cornmeal|xanthan/,
             /wet ingredients/ => /egg|milk|oil|vanilla|butter|cream|water|yogurt|extract|honey|syrup/,
             /(all|remaining|the rest of the|other) (the )?ingredients|everything|all of the ingredients/ => /./,
             /\b(spices|seasonings?|toppings?|garnish(es)?)\b/ => /salt|pepper|cumin|paprika|oregano|chili|powder|garnish|cilantro|parsley|herb|seed|flakes|cinnamon|spice/ }
  stop = %w[cup cups tbsp tsp teaspoon teaspoons tablespoon tablespoons large small medium fresh chopped minced diced sliced ground optional plus more taste about
            pinch dash whole finely roughly thinly room temperature softened melted unsalted salted cold warm divided packed cooked raw extra virgin each pound pounds ounce ounces
            grams gram inch pieces piece cans can package packages see recipe infused cannabis weed with into your favorite favourite other such store bought homemade plain
            light dark white sweet good quality fine coarse kosher sea juiced juice zest peeled seeded cubed halved quartered torn shredded grated crushed toasted for and the of or to
            serving servings garnish (optional) mold molds bag bags container liner liners paper parchment]
  p[:ings].each_with_index do |l, i|
    next if l.match?(/\A(for the|topping|optional|equipment|you will need)/i) && l.split.size < 4
    words = l.downcase.sub(/\(.*?\)/, " ").scan(/[a-z][a-z'-]{2,}/) - stop
    next if words.empty?
    next if l.match?(/\b(sauce ?pan|pan|whisk|cheesecloth|jars?|molds?|thermometer|bottles?|strainer|blender|tray|sheet|skewers?|ramekins?|tin|bag|dropper)\b/i) && !l.match?(/\d/)
    next if covers.any? { |cre, ire| stext.match?(cre) && l.downcase.match?(ire) }
    stem = ->(w) { w.sub(/(es|s)\z/, "").sub(/ies\z/, "y")[0, 6] }
    next if words.any? { |w| stext.include?(stem.(w)) }
    fail!("4d unused ingredient", slug, "all", "ingredient #{i + 1}", "never named in the steps: #{l}")
  end
end
# one shelf life per page and storage place (every language)
LANGS.each do |lang|
  SLUGS.each do |slug|
    claims = storage_claims(site, PAGES[lang][slug], lang)
    claims.group_by(&:first).each do |kind, cs|
      cs = cs.select { |_, (_, hi), _, _| hi >= 1 } # shorter ones are setting/chilling times
      vals = cs.map { |_, d, _, _| d }.uniq
      next if vals.size < 2
      fail!("4e shelf life", slug, lang, cs.map { |c| c[2] }.uniq.join(" + "),
            "#{kind}: #{vals.map { |lo, hi| lo == hi ? fmt_d(hi) : "#{fmt_d(lo)}-#{fmt_d(hi)}" }.join(" / ")} | " + cs.map { |c| c[3][0, 90] }.uniq.join(" ‖ "))
    end
  end
end
BEGIN { def fmt_d(d); d >= 30 ? "#{(d / 30.0).round(1)}mo" : d >= 7 && (d % 7).zero? ? "#{(d / 7).round}w" : d < 1 ? "#{(d * 24).round}h" : "#{d.round(1)}d"; end }

# ───────── 5. broken text ─────────
EN_LEFT_UNITS = /\b(cups?|tbsp|tsp|teaspoons?|tablespoons?|ounces?|pounds?|lbs?|sticks? of butter)\b/i
EN_LEFT_WORDS = /\b(the|and|with|until|into|minutes|stir|bake|preheat|see the recipe|of the|for about|or until|your)\b/i
REPEAT_OK = /\A(\d+|ha|bye|so|very|nein|là|que|is|had|that|dan|die|der|das|uma|una|um|un)\z/i
LANGS.each do |lang|
  SLUGS.each do |slug|
    if lang != "en"
      miss = %w[intro_unique dosing_unique storage_unique variation_unique].reject { |k| site.rt(lang, slug, k) }
      fail!("5a own text not translated", slug, lang, "i18n/recipes_#{lang}.json", "falls back to English: #{miss.join(", ")}") unless miss.empty?
    end
    site.blocks(PAGES[lang][slug]).each do |src, t|
      next if lang != "en" && src.start_with?("own ") && !site.rt(lang, slug, src.sub("own ", ""))
      t.scan(/(?<![\p{L}-])(\p{L}{2,})\s+\1(?!\p{L})/i).each { |(w)| fail!("5b broken text", slug, lang, src, "repeated word '#{w} #{w}': #{t[0, 160]}") unless w.match?(REPEAT_OK) }
      t.scan(/\b(infuse[ds]?|infusion)\s+(infused|cannabis[- ]infused|cannabis)\b/i).each { |a, b| fail!("5b broken text", slug, lang, src, "'#{a} #{b}': #{t[0, 160]}") }
      fail!("5b broken text", slug, lang, src, "unfilled placeholder: #{t[0, 160]}") if t.match?(/%\{|\{\w+\}|\bundefined\b|\bnil\b|\bTODO\b|\bXXX\b|#\{/)
      next if lang == "en"
      if lang == "zh"
        en_words = t.scan(/[A-Za-z][A-Za-z'-]{2,}(?:\s+[A-Za-z][A-Za-z'-]+)*/).reject { |w| w.match?(/\A(THC|CBD|MCT|mg|ml|Jello|Jell-O|Nutella|Oreo|Dijon|Sriracha|Rice Krispies|Kahlua|Baileys|Bundt|S'mores|Mason)\z/i) }
        fail!("5c english words left", slug, lang, src, "Latin text in zh: #{en_words.uniq.first(5).join(", ")} | #{t[0, 120]}") unless en_words.empty?
      else
        u = t.scan(EN_LEFT_UNITS).flatten.uniq
        w = t.scan(EN_LEFT_WORDS).flatten.uniq.reject { |x| lang == "de" && x =~ /\A(stir|bake)\z/i }
        fail!("5c english words left", slug, lang, src, "English words: #{w.join(", ")} | #{t[0, 140]}") unless w.empty?
        fail!("5d english units left", slug, lang, src, "English unit words: #{u.join(", ")} | #{t[0, 120]}") unless u.empty?
      end
    end
  end
end

# ───────── 6. parity between languages ─────────
def nums(s)
  t = s.gsub(/(?<!\d)半/, " 0.5 ").gsub(/(?<!\d)两(?=[个杯汤茶颗片瓣根把勺])/, " 2 ").gsub(/(?<![\d十])一(?=[个杯汤茶颗片瓣根把勺])/, " 1 ")
  t = t.gsub(/(\d)\s*([½¼¾⅓⅔⅛])/) { ($1.to_i + FRAC[$2]).to_s }.gsub(/(\d+)\s+(\d+)\/(\d+)/) { ($1.to_i + $2.to_f / $3.to_i).to_s }
  t = t.gsub(/(\d+)\/(\d+)/) { ($1.to_f / $2.to_i).to_s }.gsub(/[½¼¾⅓⅔⅛]/) { |c| FRAC[c].to_s }
  t.scan(/\d+(?:[.,]\d+)?/).map { |x| x.tr(",", ".").to_f.round(3) }.sort
end
CONV = [->(x) { (x - 32) / 1.8 }, ->(x) { x * 2.54 }, ->(x) { x * 453.6 }, ->(x) { x * 28.35 }, ->(x) { x * 240 }, ->(x) { x * 29.6 }, ->(x) { x * 0.4536 }, ->(x) { x * 0.24 }, ->(x) { x * 1000 }, ->(x) { x / 1000.0 }].freeze
def conv_of?(b, as); as.any? { |a| CONV.each_with_index.any? { |c, i| (v = c.(a)) > 0 && (b - v).abs <= (i.zero? ? 6 : v * 0.2) } }; end
def parity_ok?(a, b)
  return true if a == b
  extra = b - a
  missing = a - b
  extra.all? { |x| conv_of?(x, a) || [1.0, 0.5, 2.0].include?(x) } && missing.all? { |x| conv_of?(x, b) || conv_of?(x, a) || b.any? { |y| conv_of?(y, [x]) } }
end
LANGS.drop(1).each do |lang|
  SLUGS.each do |slug|
    en = EN[slug]
    tr = PAGES[lang][slug]
    %i[ings steps].each do |k|
      if en[k].size != tr[k].size
        fail!("6 parity", slug, lang, k.to_s, "#{k}: en #{en[k].size}, #{lang} #{tr[k].size}")
        next
      end
      en[k].each_with_index do |l, i|
        a, b = nums(l), nums(tr[k][i])
        fail!("6 parity", slug, lang, "#{k == :ings ? "ingredient" : "step"} #{i + 1}", "numbers en #{a.inspect} vs #{lang} #{b.inspect} | #{tr[k][i][0, 110]}") unless parity_ok?(a, b)
      end
    end
    en[:own].each { |k, x| parity_ok?((a = nums(x)), (b = nums(tr[:own][k]))) || x.empty? || !site.rt(lang, slug, k) || fail!("6 parity", slug, lang, "own #{k}", "numbers en #{a.inspect} vs #{lang} #{b.inspect} | #{tr[:own][k][0, 110]}") }
  end
  # templates: once per sub-category, not per recipe
  site.sections["en"]["templates"].each do |cat, subs|
    subs.each do |sub, t|
      tl = site.sections.dig(lang, "templates", cat, sub)
      next fail!("6 parity (template)", "#{cat}/#{sub}", lang, "recipe_sections", "missing in #{lang}, falls back to English") unless tl
      t.each do |k, v|
        ev = Array(v).map { |x| x.is_a?(Hash) ? "#{x["q"]} #{x["a"]}" : x }
        lv = Array(tl[k]).map { |x| x.is_a?(Hash) ? "#{x["q"]} #{x["a"]}" : x }
        next fail!("6 parity (template)", "#{cat}/#{sub}", lang, "#{k}", "en #{ev.size} lines, #{lang} #{lv.size}") if ev.size != lv.size
        ev.each_with_index { |x, i| parity_ok?((a = nums(x)), (b = nums(lv[i]))) || fail!("6 parity (template)", "#{cat}/#{sub}", lang, "#{k}[#{i}]", "numbers en #{a.inspect} vs #{lang} #{b.inspect} | #{lv[i][0, 110]}") }
      end
    end
  end
end

# ───────── 7. unsourced health claims ─────────
HEALTH = {
  "en" => /anti-?inflammator\w*|therapeutic\w*|wellness|\bhealing\b|\bheals?\b|\bcures?\b|immun\w+|detox\w*|antioxidants?|health benefits?|good for (your )?(health|heart|gut|digestion|skin)|boosts? (your )?(metabolism|immun\w*|energy|mood|brain)|reliev\w* (pain|anxiety|stress|inflammation|nausea|insomnia|cramps)|pain relief|\banxiety\b|insomnia|sleep aid|medicinal|superfood|lowers? (cholesterol|blood)|gut health|aids? digestion|digestive (aid|health)|bioavailab\w*|absorption|absorb\w*|entourage|promotes? \w+|soothing|calming|relaxing effects/i,
  "pt" => /anti-?inflamat\w*|terapêutic\w*|bem-estar|\bcura\b|imun\w+|desintox\w*|antioxidante\w*|benefícios? (para a )?saúde|alívio|alivia\w*|ansiedade|insônia|medicinal|biodisponib\w*|absorção|absorv\w*|efeito comitiva|entourage|promove\w*|calmante|relaxante/i,
  "es" => /anti-?inflamat\w*|antiinflamat\w*|terapéutic\w*|bienestar|\bcura\b|inmun\w+|desintox\w*|antioxidante\w*|beneficios? (para la )?salud|alivi\w+|ansiedad|insomnio|medicinal|biodisponib\w*|absorción|absorb\w*|séquito|entourage|promueve\w*|calmante|relajante/i,
  "de" => /entzündungshemm\w*|therapeut\w*|Wohlbefinden|\bHeil\w*|Immun\w*|Entgift\w*|Antioxid\w*|gesundheitsförder\w*|Linder\w*|lindert|Angst|Schlaflos\w*|medizinisch\w*|Bioverfügbar\w*|Aufnahme|aufgenommen|Entourage|fördert|beruhigend|entspannend/i,
  "zh" => /抗炎|治疗|疗效|疗愈|保健|免疫|排毒|抗氧化|缓解|焦虑|失眠|药用|生物利用|吸收|随行效应|促进|舒缓|镇静|放松/,
}.freeze
PHARMA = /bioavailab|absor|biodisponib|Bioverfügbar|Aufnahme|aufgenommen|生物利用|吸收|entourage|comitiva|séquito|随行/i
LANGS.each do |lang|
  SLUGS.each do |slug|
    site.blocks(PAGES[lang][slug]).each do |src, t|
      next if src.start_with?("ingredient", "step")
      hits = t.to_enum(:scan, HEALTH[lang]).map { Regexp.last_match[0] }.uniq
      # absorption words are a claim only when they're about THC, not "tofu absorbs flavours"
      pharma, med = hits.partition { |x| x.match?(PHARMA) }
      pharma = [] unless t.match?(/THC|cannabinoid|canabin|Cannabinoid|大麻素|effect|efeito|efecto|Wirkung|效果/i)
      med -= med.grep(/anxiety|ansiedad|ansiedade|Angst|焦虑/i) if t.match?(/cause|causar|verursach|导致|引起|paranoi/i)
      soft, med = med.partition { |x| x.match?(/sooth|calm|relax|calmante|relaj|relax|beruhig|entspann|舒缓|镇静|放松|promove|promueve|fördert|促进/i) && !x.match?(/drows|sleep|wellness/i) }
      fail!("7a health claim", slug, lang, src, "#{med.join(", ")} | #{t[0, 170]}") unless med.empty?
      fail!("7c mood wording (soft)", slug, lang, src, "#{soft.join(", ")} | #{t[0, 170]}") unless soft.empty?
      fail!("7b absorption/bioavailability claim", slug, lang, src, "#{pharma.join(", ")} | #{t[0, 170]}") unless pharma.empty?
    end
  end
end

# ───────── 8. the page says what one serving is ─────────
UNITW = "squares?|bars?|pieces?|cookies?|balls?|bites?|truffles?|muffins?|slices?|wedges?|cups?|glasses?|mugs?|gummies|gummy bears|candies|servings?|portions?|bowls?|plates?|tacos?|rolls?|pancakes?|crepes?|waffles?|patties|wings?|cubes?|bars|popsicles?|pops|shots?|scoops?|cakes?|cupcakes?|donuts?|dumplings?|empanadas?|tamales?|sandwich(es)?|wraps?|burritos?|quesadillas?|skewers?|brownies|blondies|fat bombs|cups|teaspoons?|tablespoons?|tsp|tbsp|ml|jars?|ramekins?|bowls?|parfaits?|pieces"
SLUGS.each do |slug|
  p = EN[slug]
  n = p[:n].round
  t = (p[:steps] + p[:own].values + p[:ings]).join(" ")
  ok = n == 1 ||
       t.match?(/\b(one|1|each|a) (serving|portion|dose)\s+(is|=|equals|of)\b/i) ||
       t.match?(/\bper (#{UNITW})\b/io) && t.match?(/\b#{n}\b/) ||
       t.scan(/\b(?:into|makes?|yields?|serves|fill|between)\s+(?:about\s+)?(\d+)(?:\s*(?:-|–|to)\s*(\d+))?\s+(?:equal\s+|even\s+|small\s+|large\s+|bite-sized\s+|\w+\s+)?(#{UNITW})\b/io).any? { |a, b, _| (a.to_i..(b || a).to_i).cover?(n) } ||
       t.scan(/\b(\d+)(?:\s*(?:-|–|to)\s*(\d+))?\s+(?:equal\s+|even\s+|small\s+|\w+\s+)?(#{UNITW})\b/io).any? { |a, b, _| (a.to_i..(b || a).to_i).cover?(n) && n > 2 }
  fail!("8 serving unit", slug, "all", "steps/own text", "makes #{n}: no sentence says what one serving is (a square, 1 tsp, 1 glass…)") unless ok
end

# ───────── report ─────────
imp = Hash.new(0)
CSV.foreach(File.join(root, "tmp/gsc-a/Pages.csv"), headers: true) { |r| (s = r[0][%r{/recipes/([^/?#]+)}, 1]) && imp[s] += r[2].to_i } if File.exist?(File.join(root, "tmp/gsc-a/Pages.csv"))
top30 = imp.select { |s, _| SLUGS.include?(s) }.sort_by { |_, v| -v }.first(30).map(&:first)

puts "Layer 1: #{SLUGS.size} recipes × #{LANGS.size} languages. lang 'all' = checked on the English source, applies to all 5."
puts format("%-34s %7s %8s %8s %s", "check", "fails", "recipes", "in top30", "by source")
FAILS.group_by { |f| f[:check] }.sort.each do |c, fs|
  rs = fs.map { |f| f[:slug] }.uniq
  srcs = fs.map { |f| f[:src].sub(/\[\d+\]/, "").sub(/(ingredient|step) \d+/, '\1').sub(/template [^.]+\./, "template ") }.tally.sort_by { |_, v| -v }.first(3).map { |k, v| "#{k} #{v}" }.join(", ")
  langs = fs.map { |f| f[:lang] }.tally.map { |k, v| "#{k}:#{v}" }.join(" ")
  puts format("%-34s %7d %8d %8d  %s  [%s]", c, fs.size, rs.size, (rs & top30).size, srcs, langs)
end
File.write(json_out, JSON.pretty_generate(FAILS)) if json_out
