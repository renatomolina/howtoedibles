# #92: writes the translation inputs to tmp/unique/: en-1.json / en-2.json (the 4 *_unique fields per recipe, split
# in two for parallel translators) and en-vars.json (the %{base_fat} / %{cook_temp} values).
# Usage (repo root): ruby content/translations/recipes/prep.rb [slug ...]  → only those slugs, all in en-1.json
# (the stale ones the build's "*_unique translation missing or stale" warning lists). Then follow BRIEF.md and merge.rb.
require "json"
require "fileutils"
dir = "tmp/unique"
FileUtils.mkdir_p(dir)
e = JSON.parse(File.read("data/recipe_enrichment.json"))
names = JSON.parse(File.read("data/recipes.json"))["recipes"].to_h { |r| [r["slug"], r["name"]] }
F = %w[intro_unique dosing_unique storage_unique variation_unique].freeze
slugs = ARGV.empty? ? e.keys.sort : ARGV
abort "unknown slugs: #{slugs - e.keys}" unless (slugs - e.keys).empty?
half = ARGV.empty? ? (slugs.size / 2.0).ceil : slugs.size
slugs.each_slice(half).each_with_index do |part, i|
  out = part.to_h { |s| [s, { "name" => names[s] }.merge(e[s].slice(*F))] }
  File.write(File.join(dir, "en-#{i + 1}.json"), JSON.pretty_generate(out) + "\n")
end
vars = { "base_fat" => e.values.map { |v| v["base_fat"] }.compact.uniq.sort, "cook_temp" => e.values.map { |v| v["cook_temp"] }.compact.uniq.sort }
File.write(File.join(dir, "en-vars.json"), JSON.pretty_generate(vars) + "\n")
puts "#{slugs.size} recipes -> #{dir}/en-*.json; #{vars["base_fat"].size} base_fat, #{vars["cook_temp"].size} cook_temp"
