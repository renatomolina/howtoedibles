# Diff gate for the English-pages migration (redesign Phase 0, issue #71).
# Compares each English page in the working tree with its version at a git ref
# (default: master) on the fields that must not change: title, description,
# keywords, canonical, hreflang, JSON-LD (parsed), visible hero/body text, h2 ids.
#
#   ruby scripts/check_english_migration.rb [ref] [file ...]
require "nokogiri"
require "json"
require "open3"

ROOT = File.expand_path("..", __dir__)
ref = ARGV.first && !ARGV.first.end_with?(".html") ? ARGV.shift : "master"
SPECIAL = %w[index.html calculator.html donate.html 404.html articles.html about.html contact.html]
files = ARGV.empty? ? Dir.glob(File.join(ROOT, "*.html")).map { |f| File.basename(f) }.sort : ARGV

# Shell/frame that may change; everything else in <body> is content.
FRAME = "nav.navbar, .site-search-bar, footer, script, noscript, .ad-container, " \
        ".article-breadcrumbs, .related-articles, .article-related, .article-body .text-center.mt-5, " \
        ".article-toc > h3, .article-toc > h4"

def norm(s)
  s.gsub(/\s+/, " ").strip
end

# Key order doesn't matter in JSON-LD; sort keys at every level.
def canon(o)
  case o
  when Hash then o.keys.sort.map { |k| [k, canon(o[k])] }.to_h
  when Array then o.map { |v| canon(v) }
  else o
  end
end

# Normalization approved for articles (#71): every Article gets mainEntityOfPage
# and the full publisher, and the breadcrumb's last item is {title, canonical}.
# Changed headline/description/breadcrumb names are reported as NOTEs, not failures.
def split_ld(ld)
  notes = {}
  objs = ld.map do |o|
    o = Marshal.load(Marshal.dump(o))
    case o["@type"]
    when "Article"
      notes["headline"] = o.delete("headline")
      notes["Article description"] = o.delete("description")
      o.delete("mainEntityOfPage")
      o.delete("publisher")
    when "BreadcrumbList"
      last = o["itemListElement"].last
      notes["breadcrumb name"] = last.delete("name")
      last.delete("item")
    end
    JSON.generate(canon(o))
  end
  [objs.sort, notes]
end

def fields(html)
  d = Nokogiri::HTML(html)
  ld = d.css('script[type="application/ld+json"]').flat_map { |s| j = JSON.parse(s.text); j.is_a?(Array) ? j : [j] }
  ld_objs, ld_notes = split_ld(ld)
  body = d.at("body").dup
  body.css(FRAME).each(&:remove)
  [{
    "title" => d.at("title")&.text,
    "description" => d.at('meta[name="description"]')&.[]("content"),
    "keywords" => d.at('meta[name="keywords"]')&.[]("content"),
    "canonical" => d.at('link[rel="canonical"]')&.[]("href"),
    "hreflang" => d.css("link[hreflang]").map { |l| "#{l['hreflang']} #{l['href']}" }.sort,
    "json-ld" => ld_objs,
    "text" => norm(body.text),  # compared without whitespace: old markup was partly minified
    "h2 ids" => d.css("h2[id]").map { |e| e["id"] }
  }, ld_notes]
end

def same?(k, x, y)
  k == "text" ? x.gsub(/\s+/, "") == y.gsub(/\s+/, "") : x == y
end

def first_diff(a, b)
  i = (0...[a.size, b.size].min).find { |k| a[k] != b[k] } || [a.size, b.size].min
  "…#{a[[i - 60, 0].max, 140]}…\n      now: …#{b[[i - 60, 0].max, 140]}…"
end

failed = 0
files.each do |f|
  old, ok = Open3.capture2("git", "-C", ROOT, "show", "#{ref}:#{f}")
  next unless ok.success?
  a, an = fields(old)
  b, bn = fields(File.read(File.join(ROOT, f)))
  an.each { |k, v| puts "NOTE #{f} #{k}: #{v.inspect} → #{bn[k].inspect}" if v != bn[k] }
  bad = a.keys.reject { |k| same?(k, a[k], b[k]) }
  next if bad.empty?
  failed += 1
  puts "FAIL #{f}"
  bad.each do |k|
    if a[k].is_a?(String) && b[k].is_a?(String)
      puts "  #{k}: #{first_diff(a[k], b[k])}"
    else
      puts "  #{k}:\n    - #{(Array(a[k]) - Array(b[k])).join("\n    - ")[0, 600]}\n    + #{(Array(b[k]) - Array(a[k])).join("\n    + ")[0, 600]}"
    end
  end
end
puts failed.zero? ? "OK: #{files.size} pages match #{ref}" : "#{failed} of #{files.size} pages differ from #{ref}"
exit(failed.zero? ? 0 : 1)
