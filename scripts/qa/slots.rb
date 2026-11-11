# Article ad-slot gate (#55, #75), on the generated pages in all 5 languages:
# with ≥ 4 content H2s (h2#sources doesn't count) there are 2 slots, the first right before the 3rd content H2;
# the last slot sits right before h2#sources, or ends the body (right before the shell's "Read more" button).
# Frozen raw_main pages (#71) have none. Run: ruby scripts/qa/slots.rb
require "nokogiri"
require "json"

ROOT = File.expand_path("../..", __dir__)
bad = []
counts = Hash.new(0)
%w[en pt es de zh].each do |lang|
  JSON.parse(File.read(File.join(ROOT, "i18n/articles_#{lang}.json")))["articles"].each do |slug, a|
    doc = Nokogiri::HTML(File.read(File.join(ROOT, lang == "en" ? "" : lang, "#{slug}.html")))
    all = doc.css("aside.ad")
    next bad << "#{lang} #{slug}: frozen page has #{all.size} slots" if a["raw_main"] && !all.empty?
    next if a["raw_main"]
    kids = doc.at("article.article-body").element_children.to_a
    slot = ->(e) { e&.name == "aside" && e["class"] == "ad" }
    h2 = kids.select { |e| e.name == "h2" }
    sources = h2.find { |e| e["id"] == "sources" }
    content = h2 - [sources]
    want = content.size >= 4 ? 2 : 1
    last = sources || kids.reverse.find { |e| e["class"].to_s.include?("text-center") }
    errs = []
    errs << "#{all.size} slots, want #{want}" if all.size != want || kids.count(&slot) != want
    errs << "no slot before the 3rd content H2" if want == 2 && !slot.(content[2].previous_element)
    errs << "no slot before #{sources ? "h2#sources" : "the end of the body"}" unless slot.(last&.previous_element)
    bad << "#{lang} #{slug}: #{errs.join("; ")}" unless errs.empty?
    bad << "#{lang} #{slug}: the bad-trip article must have the end slot only" if slug == "how-to-prevent-a-bad-trip" && all.size != 1
    counts[all.size] += 1
  end
end
puts bad.empty? ? "Slots OK: #{counts.sort.map { |n, k| "#{k} articles with #{n}" }.join(", ")}" : bad
exit(bad.empty? ? 0 : 1)
