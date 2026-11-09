# PROTOTYPE helper: route the pages prototype's side tables (NEXT, FREE, donate labels, SEE) and already-existing
# strings through T / D.c, so every string it shows comes from strings.js or i18n/{lang}.json.
f = ARGV[0]
h = File.read(f)
rep = {
  "${t().updated}" => '${t().updated(new Intl.DateTimeFormat(S.lang === "zh" ? "zh-CN" : S.lang, { month: "long", year: "numeric" }).format(new Date(2026, 2)))}',
  "t().guideT" => "D.c.dosage_guide_title",
  "${t().lvlH}" => "${D.c.dosage_level}", "${t().mgH}" => "${D.c.dosage_per_serving}", "${t().effH}" => "${D.c.dosage_effects}",
  "${t().tryT}" => "${D.c.try_recipe_title}", "${t().tryS}" => "${D.c.try_recipe_sub}",
  "n = NEXT[S.lang]" => "n = { q: t().nextQ, s: t().nextS, first: t().first, arts: D.ui.articles.title }",
  "FREE[S.lang]" => "t().free",
}
rep.each { |a, b| h.include?(a) or abort("missing: #{a}"); h.gsub!(a, b) }
h.sub!(/const L = \{ en: \["Recipes".*?\}\[S\.lang\];/, "const L = t().facts;") or abort "donate L"
h.sub!(/const SEE = \{ en:.*?\}\[S\.lang\];/, "const SEE = t().seeAll;") or abort "SEE"
File.write(f, h)
puts "patched #{f}"
