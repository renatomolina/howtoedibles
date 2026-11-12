# #92: validates tmp/unique/{lang}-{1,2}.json (+ {lang}-vars.json) and merges them into i18n/recipes_{lang}.json
# (the 4 *_unique fields + unique_src, the hash of the English the build compares) and i18n/recipe_vars.json.
# Usage (repo root): ruby content/translations/recipes/merge.rb [--check]. Partial input is fine: slugs and vars files
# that aren't there keep their current translation. NUMBERS lines are for a human to read (e.g. "six" → 6 is fine).
require "json"
require "digest"
dir = "tmp/unique"
F = %w[intro_unique dosing_unique storage_unique variation_unique].freeze
e = JSON.parse(File.read("data/recipe_enrichment.json"))
en_vars = JSON.parse(File.read(File.join(dir, "en-vars.json")))
src = ->(x) { Digest::SHA1.hexdigest(F.map { |k| x[k].to_s }.join("\n")) } # same as unique_src in build_site.rb
nums = ->(s) { s.to_s.scan(/\d+(?:[.,]\d+)?/).map { |n| n.tr(",", ".").sub(/\.0+\z/, "") }.sort }
check_only = ARGV.include?("--check")
errors = []

# The build swaps these words when they are among the 2 before %{base_fat}: the templates assume pt/es masculine
# and de neuter (for a de masculine fat the accusative, the usual case in a recipe step).
AGREE = {
  "pt" => { "f" => { "o" => "a", "O" => "A", "seu" => "sua", "Seu" => "Sua", "do" => "da", "no" => "na", "ao" => "à", "um" => "uma", "Um" => "Uma", "muito" => "muita", "pelo" => "pela", "este" => "esta", "esse" => "essa" } },
  "es" => { "f" => { "el" => "la", "El" => "La", "del" => "de la", "al" => "a la", "un" => "una", "Un" => "Una", "demasiado" => "demasiada", "mucho" => "mucha", "este" => "esta" } },
  "de" => { "f" => { "das" => "die", "Das" => "Die", "dein" => "deine", "Dein" => "Deine", "deinem" => "deiner", "dem" => "der", "im" => "in der", "vom" => "von der", "zum" => "zur",
                     "ein" => "eine", "geschmolzenem" => "geschmolzener", "hochwertiges" => "hochwertige", "gefiltertes," => "gefilterte,", "infundiertes" => "infundierte" },
            "m" => { "das" => "den", "Das" => "Den", "dein" => "deinen", "Dein" => "Deinen", "ein" => "einen", "hochwertiges" => "hochwertigen", "gefiltertes," => "gefilterten,", "infundiertes" => "infundierten" } },
  "zh" => {},
}.freeze

vars_path = "i18n/recipe_vars.json"
vars_out = File.exist?(vars_path) ? JSON.parse(File.read(vars_path)) : {}
%w[pt es de zh].each do |lang|
  tr = {}
  [1, 2].each { |part| f = File.join(dir, "#{lang}-#{part}.json"); tr.merge!(JSON.parse(File.read(f))) if File.exist?(f) }
  (tr.keys - e.keys).each { |s| errors << "#{lang}: unknown slug #{s}" }
  tr.each do |slug, t|
    next unless e[slug]
    F.each do |k|
      next errors << "#{lang}/#{slug}: #{k} empty" if t[k].to_s.strip.empty?
      a, b = nums.(e[slug][k]), nums.(t[k])
      puts "NUMBERS #{lang}/#{slug}/#{k}: en #{a.inspect} vs #{b.inspect}" unless a == b
    end
    errors << "#{lang}/#{slug}: extra keys #{t.keys - F}" unless (t.keys - F).empty?
  end

  vf = File.join(dir, "#{lang}-vars.json")
  if File.exist?(vf)
    v = JSON.parse(File.read(vf))
    %w[base_fat cook_temp].each do |k|
      (en_vars[k] - v[k].to_h.keys - vars_out.dig(lang, k).to_h.keys).each { |x| errors << "#{lang}-vars: #{k} #{x.inspect} missing" }
    end
    fats = v["base_fat"].to_h.slice(*en_vars["base_fat"])
    fats.each { |x, (t, g)| errors << "#{lang}-vars: base_fat #{x.inspect} bad gender #{g.inspect}" unless (lang == "zh" ? [""] : lang == "de" ? %w[m f n] : %w[m f]).include?(g.to_s) && !t.to_s.empty? }
    old = vars_out[lang] || {}
    vars_out[lang] = { "base_fat" => old["base_fat"].to_h.merge(fats), "cook_temp" => old["cook_temp"].to_h.merge(v["cook_temp"].to_h.slice(*en_vars["cook_temp"])) }
  end
  vars_out[lang] = (vars_out[lang] || {}).merge("agree" => AGREE[lang])

  next if check_only || errors.any? || tr.empty?
  path = "i18n/recipes_#{lang}.json"
  raw = File.read(path)
  data = JSON.parse(raw)
  abort "#{path}: round-trip not byte-identical" unless JSON.pretty_generate(data) == raw.chomp
  tr.each { |slug, t| data[slug] = (data[slug] || {}).merge(t.slice(*F), "unique_src" => src.(e[slug])) }
  File.write(path, JSON.pretty_generate(data) + (raw.end_with?("\n") ? "\n" : ""))
  puts "#{lang}: merged #{tr.size} recipes"
end

if errors.any?
  puts errors.map { |x| "ERROR #{x}" }
  exit 1
end
File.write(vars_path, JSON.pretty_generate(vars_out) + "\n") unless check_only
