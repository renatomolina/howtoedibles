# PROTOTYPE: copy fixes from fit run 2 (each one is a string that broke a one-line control or the first screen)
f = File.join(__dir__, "strings.js")
s = File.read(f)
{
  # facts-row label wrapped to 2 lines in es (≤375) and pushed the hero buttons below the first screen
  'es: "Receta completa"' => 'es: "Receta entera"',
  # hero button wrapped in en/pt (≤390) and es (≤360)
  'en: "Jump to recipe", pt: "Ir para a receita", es: "Ir a la receta"' => 'en: "Go to recipe", pt: "Ver receita", es: "Ver receta"',
  # help link wrapped in the menu at 344 (pt/es)
  'pt: "Passou do ponto? Ajuda agora", es: "¿Te pasaste? Pide ayuda ahora"' => 'pt: "Bateu forte? Peça ajuda", es: "¿Te pasaste? Pide ayuda"',
}.each { |a, b| s.include?(a) or abort("missing #{a}"); s.sub!(a, b) }
# compact-bar pill truncated in every language (en too) up to 390px: no count in the pill; the dialog placeholder keeps it
s.sub!('  "shell.search": ', '  "shell.search_short": { en: "Search recipes", pt: "Buscar receitas", es: "Buscar recetas", de: "Rezepte suchen", zh: "搜索食谱" },' + "\n" + '  "shell.search": ') or abort "pill"
File.write(f, s)
# pills in the 4 prototypes read the short key
pill = { "recipes/_prototype-homepage/index.html" => '${T[S.lang].search(D.list.length)}</span></span><span class="ibtn">',
         "recipes/_prototype-recipe-final/index.html" => '${t().search(D.rec.recipes.length)}</span></span>',
         "_prototype-pages/index.html" => '${t().search(D.rec.recipes.length)}</span></span>',
         "recipes/_prototype-navigation/index.html" => '${t.ph(D.list.length)}</span></button>' }
pill.each do |p, a|
  file = File.join(__dir__, "..", p); h = File.read(file)
  h.include?(a) or abort("pill missing in #{p}")
  File.write(file, h.sub(a, a.sub(/\$\{[^}]+\}/) { |m| m.start_with?("${T[") ? "${T[S.lang].pill}" : m.start_with?("${t.") ? "${t.pill}" : "${t().pill}" }))
end
puts "ok"
