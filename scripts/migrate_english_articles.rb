# One-off (redesign Phase 0, #71): move the hand-maintained article pages into
# i18n/articles_{lang}.json, in the translations' schema.
#   - the 50 English articles → i18n/articles_en.json
#   - the 88 orphan translated pages (no JSON generated them) → frozen verbatim
#     in i18n/articles_{lang}.json as "raw_main" + "schema"
#   - translations: drop the stray TOC <ul> and set the real date_modified
# Run against pristine HTML (git checkout master -- '*.html' '*/*.html').
require "nokogiri"
require "json"
require "open3"

ROOT = File.expand_path("..", __dir__)
SPECIAL = %w[index.html calculator.html donate.html 404.html articles.html about.html contact.html]
STD_LD = %w[Article BreadcrumbList FAQPage]
FRAME = ".text-center.mt-5, .related-articles, .article-related"

def extract(path)
  d = Nokogiri::HTML(File.read(path))
  ld = d.css('script[type="application/ld+json"]').flat_map { |s| j = JSON.parse(s.text); j.is_a?(Array) ? j : [j] }
  art = ld.find { |o| o["@type"] == "Article" }
  faq = ld.find { |o| o["@type"] == "FAQPage" }
  hero = d.at_css("section.article-hero")
  meta = hero.css(".article-meta span").map { |s| s.text.strip }
  col = d.at_css("article.article-body .col-lg-8")

  related = d.css(".related-articles a[href], .article-related a[href]").map do |a|
    card = a.ancestors(".card, .article-related-card").first || a
    { "slug" => a["href"][%r{/([^/]+)\.html}, 1], "title" => (card.at_css("h4, h5") || a).text.strip,
      "description" => card.at_css("p")&.text&.strip }.compact
  end.uniq { |r| r["slug"] }

  toc_el = col.at_css("> .article-toc")
  toc = toc_el.css("li a").map { |a| { "id" => a["href"].delete_prefix("#"), "text" => a.text.strip } }
  toc_el.replace(Nokogiri::XML::Comment.new(d, " toc "))
  col.css(FRAME).each(&:remove)
  col.xpath("comment()[normalize-space(.)='Table of Contents']").each(&:remove)

  title = d.at('meta[property="og:title"]')["content"]
  h1 = hero.at_css("h1").text.strip
  {
    "title" => title,
    "h1" => (h1 == title ? nil : h1),
    "description" => d.at('meta[name="description"]')["content"],
    "keywords" => d.at('meta[name="keywords"]')&.[]("content"),
    "category" => hero.at_css(".article-category").text.strip,
    "excerpt" => hero.at_css(".article-excerpt")&.text&.strip,
    "date_published" => art["datePublished"],
    "date_modified" => art["dateModified"],
    "show_updated" => meta.any? { |m| m.start_with?("Updated") } || nil,
    "read_time" => meta.last,
    "toc" => toc,
    "body_html" => col.children.to_html.strip,
    "faq" => (faq ? faq["mainEntity"].map { |q| { "question" => q["name"], "answer" => q["acceptedAnswer"]["text"] } } : []),
    "related" => related,
    "schema_extra" => (ld.reject { |o| STD_LD.include?(o["@type"]) }.then { |x| x.empty? ? nil : x })
  }.compact
end

# Orphan translated pages are frozen verbatim: 37 are real translations, 23 have
# an English body and 28 have two articles stuck together. Their fate is a content
# decision for the traffic map; until then only the shell around raw_main changes.
def freeze(path)
  d = Nokogiri::HTML(File.read(path))
  start = d.at_css("body > .site-search-bar")
  main = []
  node = start.next_sibling
  until node.nil? || (node.element? && node.name == "footer")
    main << node
    node = node.next_sibling
  end
  {
    "title" => d.at("title").text.delete_suffix(" | HowToEdibles"),
    "description" => d.at('meta[name="description"]')["content"],
    "keywords" => d.at('meta[name="keywords"]')&.[]("content"),
    "schema" => d.css('script[type="application/ld+json"]').flat_map { |s| j = JSON.parse(s.text); j.is_a?(Array) ? j : [j] },
    "raw_main" => main.map(&:to_html).join.strip
  }.compact
end

en_path = File.join(ROOT, "i18n", "articles_en.json")
en = File.exist?(en_path) ? JSON.parse(File.read(en_path)) : { "articles_index" => {} }
en["articles"] = {}
(Dir.glob(File.join(ROOT, "*.html")).map { |f| File.basename(f) } - SPECIAL).sort.each do |f|
  en["articles"][f.delete_suffix(".html")] = extract(File.join(ROOT, f))
end
File.write(en_path, JSON.pretty_generate(en) + "\n")
puts "en: #{en['articles'].size} articles"

%w[pt es de zh].each do |l|
  path = File.join(ROOT, "i18n", "articles_#{l}.json")
  data = JSON.parse(File.read(path))
  data["articles"].reject! { |_, a| a["untranslated"] || a["raw_main"] }
  old = JSON.parse(Open3.capture2("git", "-C", ROOT, "show", "359e8a11:i18n/articles_#{l}.json")[0])["articles"]
  stripped = dated = 0
  data["articles"].each do |slug, a|
    if (m = a["body_html"].match(/\A\s*<ul>(.*?)<\/ul>\s*/m)) && m[1].scan(/href="([^"]*)"/).flatten.all? { |h| h.start_with?("#") }
      a["body_html"] = m.post_match
      stripped += 1
    end
    same = old[slug] && old[slug].reject { |k, _| k =~ /date|body_html/ } == a.reject { |k, _| k =~ /date|body_html/ } &&
           old[slug]["body_html"].include?(a["body_html"])
    if !same && a["date_modified"] == a["date_published"]
      a["date_modified"] = en["articles"][slug]["date_modified"]
      dated += 1
    end
  end

  orphans = (Dir.glob(File.join(ROOT, l, "*.html")).map { |f| File.basename(f, ".html") } -
             SPECIAL.map { |s| s.delete_suffix(".html") } - data["articles"].keys).sort
  orphans.each { |slug| data["articles"][slug] = freeze(File.join(ROOT, l, "#{slug}.html")) }

  File.write(path, JSON.pretty_generate(data) + "\n")
  puts "#{l}: stripped stray TOC from #{stripped}, date_modified updated on #{dated}, froze #{orphans.size} orphan pages"
end
