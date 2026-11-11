# Checkpoint reader for a GSC "Compare" export (Performance → Search results → Date → Compare → Export → CSV, unzipped).
# Prints clicks/impressions per day for the two ranges by URL group and language, the tests in flight (#85 calculator,
# #86 firecrackers vs the other photo recipes of #93), the biggest page moves and the Recipe Gallery.
#   ruby scripts/checkpoint.rb <export dir>
require "csv"
require "date"

dir = ARGV[0] or abort "usage: ruby scripts/checkpoint.rb <unzipped GSC compare export>"
SITE = "https://www.howtoedibles.com"

# "9/1/26 - 9/14/26 Clicks" → [Date, Date]; the two ranges in date order, whatever order GSC wrote them in
def ranges(header)
  header.filter_map { |h| h[%r{\A(\d+/\d+/\d+) - (\d+/\d+/\d+) Clicks\z}] && [$1, $2].map { |d| Date.strptime(d, "%m/%d/%y") } }.uniq
end

def load(file)
  t = CSV.read(file, headers: true)
  rs = ranges(t.headers)
  abort "#{file}: not a Compare export (needs two date ranges)" unless rs.size == 2
  before, after = rs.sort
  col = ->(r, k) { "#{r[0].strftime("%-m/%-d/%y")} - #{r[1].strftime("%-m/%-d/%y")} #{k}" }
  days = ->(r) { (r[1] - r[0]).to_i + 1 }
  rows = t.map do |x|
    { key: x[0], cb: x[col.(before, "Clicks")].to_i, ca: x[col.(after, "Clicks")].to_i, ib: x[col.(before, "Impressions")].to_i,
      ia: x[col.(after, "Impressions")].to_i, pb: x[col.(before, "Position")].to_f, pa: x[col.(after, "Position")].to_f }
  end
  [rows, days.(before), days.(after), before, after]
end

pct = ->(a, b) { a.zero? ? (b.zero? ? "    —" : "  new") : format("%+4.0f%%", (b / a - 1) * 100) }
line = lambda do |label, rows, db, da|
  cb, ca = rows.sum { _1[:cb] } / db.to_f, rows.sum { _1[:ca] } / da.to_f
  ib, ia = rows.sum { _1[:ib] } / db.to_f, rows.sum { _1[:ia] } / da.to_f
  format("  %-30s clicks/day %6.1f → %6.1f %s · impr/day %7.0f → %7.0f %s · CTR %5.2f%% → %5.2f%%", label, cb, ca, pct.(cb, ca), ib, ia, pct.(ib, ia), ib.zero? ? 0 : 100 * cb / ib, ia.zero? ? 0 : 100 * ca / ia)
end

pages, db, da, before, after = load(File.join(dir, "Pages.csv"))
puts "Before #{before.join(" – ")} (#{db} d) · after #{after.join(" – ")} (#{da} d). Per-day numbers; the export holds GSC's top 1,000 rows."
path = ->(u) { u.delete_prefix(SITE).sub(%r{\A/(pt|es|de|zh)(?=/)}, "") }
lang = ->(u) { u[%r{\A#{SITE}/(pt|es|de|zh)/}, 1] || "en" }
group = lambda do |u|
  case path.(u)
  when %r{\A/recipes/} then "recipes"
  when %r{\A/category/} then "categories"
  when %r{\A/(index\.html)?\z} then "home"
  when %r{\A/(calculator\.html|edible-dosage-calculator)} then "calculator"
  when %r{\A/(donate|articles)\.html} then "donate + articles index"
  when %r{\A/(about|contact)\.html} then "about + contact"
  when %r{\A/[^/]+\.html\z} then "articles"
  else "other (old URLs)"
  end
end

puts "\n== Whole site", line.("all pages", pages, db, da)
puts "\n== By URL group"
pages.group_by { group.(_1[:key]) }.sort_by { -_2.sum { |r| r[:cb] } }.each { |g, l| puts line.(g, l, db, da) }
puts "\n== By language"
pages.group_by { lang.(_1[:key]) }.sort_by { -_2.sum { |r| r[:cb] } }.each { |g, l| puts line.(g, l, db, da) }

puts "\n== #85 calculator URLs (English)"
pages.select { |r| r[:key].match?(%r{\A#{SITE}/(calculator\.html|edible-dosage-calculator/?)\z}) }.each { |r| puts line.(path.(r[:key]), [r], db, da) }

photos = Dir.glob(File.join(__dir__, "..", "images/photos/*-1x1.jpg")).map { File.basename(_1, "-1x1.jpg") }
unless photos.empty?
  en = pages.select { |r| lang.(r[:key]) == "en" && r[:key].match?(%r{/recipes/[^/]+/\z}) }
  slug = ->(r) { r[:key][%r{/recipes/([^/]+)/\z}, 1] }
  ctr = ->(r, s) { i = r[:"i#{s}"]; i.zero? ? nil : r[:"c#{s}"].to_f / i }
  change = ->(r) { b, a = ctr.(r, "b"), ctr.(r, "a"); b && a && b.positive? ? a / b - 1 : nil }
  ctl = en.select { |r| photos.include?(slug.(r)) && slug.(r) != "firecrackers" }.filter_map(&change).sort
  fc = en.find { |r| slug.(r) == "firecrackers" }
  puts "\n== #86 firecrackers (title + photo) vs the other English photo recipes of #93 (photo only)"
  puts line.("/recipes/firecrackers/", [fc], db, da) if fc
  if fc && change.(fc) && !ctl.empty?
    med = ctl[ctl.size / 2]
    puts format("  CTR change: firecrackers %+.0f%% · median of %d photo-only recipes %+.0f%% → the title's own effect ≈ %+.0f points", change.(fc) * 100, ctl.size, med * 100, (change.(fc) - med) * 100)
  end
end

puts "\n== Biggest page moves (clicks/day)"
moves = pages.map { |r| [r[:ca] / da.to_f - r[:cb] / db.to_f, r] }.sort_by(&:first)
(moves.first(8) + moves.last(5).reverse).each { |d, r| puts format("  %+6.1f  %-60s pos %5.1f → %5.1f", d, path.(r[:key]) + (lang.(r[:key]) == "en" ? "" : " [#{lang.(r[:key])}]"), r[:pb], r[:pa]) }

sa = File.join(dir, "Search appearance.csv")
if File.exist?(sa)
  rows, = load(sa)
  puts "\n== Search appearance (#91 Recipe Gallery)"
  rows.each { |r| puts line.(r[:key], [r], db, da) }
end

q = File.join(dir, "Queries.csv")
if File.exist?(q)
  rows, = load(q)
  calc = rows.select { _1[:key].match?(/calcul|rechner|计算/i) }
  puts "\n== Calculator queries (#85: #{calc.size} variants)", line.("all calculator queries", calc, db, da)
end
