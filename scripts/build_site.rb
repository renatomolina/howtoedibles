#!/usr/bin/env ruby
# scripts/build_site.rb
# Generates every page; about.html and contact.html keep their hand-maintained body (see CLAUDE.md).
#
# Run: ruby scripts/build_site.rb

require "json"
require "fileutils"
require "cgi"
require "date"
require "digest"

ROOT_DIR   = File.expand_path("..", __dir__)
DATA_FILE  = File.join(ROOT_DIR, "data", "recipes.json")
I18N_DIR   = File.join(ROOT_DIR, "i18n")

abort "ERROR: #{DATA_FILE} not found." unless File.exist?(DATA_FILE)

data       = JSON.parse(File.read(DATA_FILE))
CATEGORIES = data["categories"]
RECIPES    = data["recipes"]

# ─────────────────────────────────────────────
# i18n Loading
# ─────────────────────────────────────────────

LANGS = %w[pt es de zh]  # the translations (recipes_{lang}.json, the sitemap's article alternates)
ALL_LANGS = %w[en pt es de zh]  # for hreflang tags
RECIPE_LANGS = ALL_LANGS  # recipes now generated for all languages including English

I18N = {}
ALL_LANGS.each do |lang|
  path = File.join(I18N_DIR, "#{lang}.json")
  if File.exist?(path)
    I18N[lang] = JSON.parse(File.read(path))
  else
    warn "WARNING: #{path} not found, using English fallback for '#{lang}'"
    I18N[lang] = {}
  end
end

RECIPE_I18N = {}
LANGS.each do |lang|
  path = File.join(I18N_DIR, "recipes_#{lang}.json")
  if File.exist?(path)
    RECIPE_I18N[lang] = JSON.parse(File.read(path))
  else
    warn "WARNING: #{path} not found, recipes will use English for '#{lang}'"
    RECIPE_I18N[lang] = {}
  end
end

ARTICLE_I18N = {}
ALL_LANGS.each do |lang|
  path = File.join(I18N_DIR, "articles_#{lang}.json")
  if File.exist?(path)
    ARTICLE_I18N[lang] = JSON.parse(File.read(path))
  else
    warn "WARNING: #{path} not found, articles will use English for '#{lang}'"
    ARTICLE_I18N[lang] = {}
  end
end

# Load per-recipe enrichment data
ENRICHMENT_FILE = File.join(ROOT_DIR, "data", "recipe_enrichment.json")
ENRICHMENT = File.exist?(ENRICHMENT_FILE) ? JSON.parse(File.read(ENRICHMENT_FILE)) : {}

# Load recipe section templates per language
RECIPE_SECTIONS = {}
ALL_LANGS.each do |lang|
  path = File.join(I18N_DIR, "recipe_sections_#{lang}.json")
  if File.exist?(path)
    RECIPE_SECTIONS[lang] = JSON.parse(File.read(path))
  else
    warn "WARNING: #{path} not found, recipe sections will use English fallback for '#{lang}'"
    RECIPE_SECTIONS[lang] = {}
  end
end

RECIPE_I18N["en"] = {} # English recipes use data directly from recipes.json

# #92: the per-recipe sentences (*_unique) are translated into recipes_{lang}.json with "unique_src", a hash of the
# English they came from, and %{base_fat}/%{cook_temp} values into recipe_vars.json. When the English changes or
# gains a value, the page falls back to English (or keeps the old translation), so say so instead of failing the build.
UNIQUE_FIELDS = %w[intro_unique dosing_unique storage_unique variation_unique].freeze
def unique_src(enrich)
  Digest::SHA1.hexdigest(UNIQUE_FIELDS.map { |k| enrich[k].to_s }.join("\n"))
end
RECIPE_VARS = JSON.parse(File.read(File.join(I18N_DIR, "recipe_vars.json")))
LANGS.each do |lang|
  stale = ENRICHMENT.select { |slug, e| (s = RECIPE_I18N[lang].dig(slug, "unique_src")).nil? || s != unique_src(e) }.keys
  missing = %w[base_fat cook_temp].flat_map { |k| ENRICHMENT.values.map { |e| e[k] }.compact.uniq.reject { |v| RECIPE_VARS.dig(lang, k, v) } }
  warn "WARNING: #{lang}: *_unique translation missing or stale for #{stale.size} recipes: #{stale.first(12).join(", ")} (content/translations/recipes/BRIEF.md)" if stale.any?
  warn "WARNING: #{lang}: no translation in i18n/recipe_vars.json for #{missing.uniq.join(" | ")} (content/translations/recipes/BRIEF.md)" if missing.any?
end

puts "Building site from #{RECIPES.count} recipes across #{CATEGORIES.count} categories in #{ALL_LANGS.count} languages..."
puts "Recipe pages generated for ALL languages (en, pt, es, de, zh)."

# ─────────────────────────────────────────────
# Translation Helpers
# ─────────────────────────────────────────────

def t(lang, *keys)
  result = I18N[lang]
  keys.each { |k| result = result.is_a?(Hash) ? result[k.to_s] : nil }
  if result.nil?
    result = I18N["en"]
    keys.each { |k| result = result.is_a?(Hash) ? result[k.to_s] : nil }
  end
  result || keys.last.to_s
end

def recipe_t(lang, slug, field)
  RECIPE_I18N.dig(lang, slug, field)
end

def category_t(lang, cat_name)
  t(lang, "categories", cat_name) || cat_name
end

def h(text)
  CGI.escapeHTML(text.to_s)
end

def lang_prefix(lang)
  lang == "en" ? "" : "/#{lang}"
end

NAMED_ENTITIES = { "nbsp" => " ", "frac12" => "½", "frac14" => "¼", "frac34" => "¾",
                   "frac13" => "⅓", "frac23" => "⅔", "frac18" => "⅛", "deg" => "°", "ndash" => "–",
                   "mdash" => "—", "times" => "×" }.freeze

def decode_entities(s)
  CGI.unescapeHTML(s.gsub(/&(#{NAMED_ENTITIES.keys.join('|')});/) { NAMED_ENTITIES[$1] })
end

# 48.0 -> "48", 3.5 -> "3.5"
def fmt_num(n)
  n.to_f == n.to_i ? n.to_i.to_s : n.to_s
end

def lang_html(lang)
  case lang
  when "pt" then "pt-BR"
  when "zh" then "zh-Hans"
  else lang
  end
end

# ─────────────────────────────────────────────
# Output Helpers
# ─────────────────────────────────────────────

def output_path(lang, *segments)
  if lang == "en"
    File.join(ROOT_DIR, *segments)
  else
    File.join(ROOT_DIR, lang, *segments)
  end
end

# The English calculator is back at the URL it ranked on until the March 2026 migration; calculator.html redirects
# there. Every link and absolute URL to /calculator.html (menus, bodies, about/contact, canonical, hreflang, the
# sitemap) is rewritten once, here. The other languages keep /{lang}/calculator.html.
EN_CALC = "/edible-dosage-calculator/"

def write_file(path, content)
  content = content.gsub(%r{(href="|https://www\.howtoedibles\.com)/calculator\.html}, "\\1#{EN_CALC}") if path.end_with?(".html", ".xml")
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

# ─────────────────────────────────────────────
# hreflang tags for all pages
# ─────────────────────────────────────────────

def hreflang_tags(page_path, langs = ALL_LANGS)
  # page_path is the language-neutral path like "" (homepage), "calculator.html", "recipes/cannabutter/"
  # Strip any leading lang prefix if accidentally included
  page_path = page_path.sub(%r{^(pt|es|de|zh)/}, "")
  return "" if langs.size < 2
  tags = []
  langs.each do |l|
    prefix = l == "en" ? "" : "/#{l}"
    href = "https://www.howtoedibles.com#{prefix}/#{page_path}"
    # Normalize: no double slashes, root ends with /
    href = href.gsub("//", "/").sub("https:/", "https://")
    href = href.sub(/\/?$/, "/") if page_path.empty? || page_path.end_with?("/")
    html_lang = lang_html(l)
    tags << %(<link rel="alternate" hreflang="#{html_lang}" href="#{href}" />)
  end
  xdef = "https://www.howtoedibles.com/#{page_path}"
  xdef = xdef.sub(/\/?$/, "/") if page_path.empty? || page_path.end_with?("/")
  tags << %(<link rel="alternate" hreflang="x-default" href="#{xdef}" />)
  tags.join("\n  ")
end

COOKING_EFFICIENCY = 0.80  # must match COOKING_EFFICIENCY in js/dose.js

# ═════════════════════════════════════════════
# PAGE BUILDERS
# ═════════════════════════════════════════════

# ─────────────────────────────────────────────
# Recipe enrichment helpers
# ─────────────────────────────────────────────

def interpolate(template, vars)
  return template unless template.is_a?(String)
  result = template.dup
  vars.each { |k, v| result.gsub!("%{#{k}}", v.to_s) }
  # Templates say "cannabis %{name}" / "cannabis %{base_fat}", but names and fats
  # often already say it ("Cannabis Carbonara", "cannabutter").
  result.gsub(/\b(cannabis)\s+(cannabis|cannabutter)\b/i) { $2.casecmp?("cannabis") ? $1 : $2 }
end

# Category mapping for merged template categories
TEMPLATE_CATEGORY_MAP = {}

def get_recipe_section_template(lang, category, sub_category)
  cat = TEMPLATE_CATEGORY_MAP[category] || category
  sections = RECIPE_SECTIONS.dig(lang, "templates", cat, sub_category)
  sections || RECIPE_SECTIONS.dig("en", "templates", cat, sub_category) || {}
end

def get_section_label(lang, key)
  RECIPE_SECTIONS.dig(lang, "section_labels", key) ||
    RECIPE_SECTIONS.dig("en", "section_labels", key) || key
end

# ─────────────────────────────────────────────
# Recipe pages
# ─────────────────────────────────────────────

FLOWER_AMOUNT_RE = /(\d+(?:[.,]\d+)?)(\s*(?:gramas?\b|gramos?\b|Gramm\b|g\b|克))?(\s*(?:de\s+)?)(ground\s*weed|maconha triturada|erva moída|cannabis moída|marihuana molida|hierba molida|cannabis molida|gemahlenes Gras|gemahlenes Cannabis|研磨好的大麻|研磨大麻)/i

# ─────────────────────────────────────────────
# Sitemap (with hreflang)
# ─────────────────────────────────────────────

def build_sitemap
  urls = []

  # Static pages
  static_pages = ["", "calculator.html", "donate.html", "articles.html"]

  static_pages.each do |page|
    # All language versions
    xhtml_links = ALL_LANGS.map do |l|
      lang_seg = l == "en" ? nil : l
      path = [lang_seg, page.empty? ? nil : page].compact.join("/")
      href = if path.empty?
        "https://www.howtoedibles.com/"
      elsif page.empty?
        "https://www.howtoedibles.com/#{path}/"
      else
        "https://www.howtoedibles.com/#{path}"
      end
      html_lang = lang_html(l)
      %(    <xhtml:link rel="alternate" hreflang="#{html_lang}" href="#{href}" />)
    end
    xdef_href = page.empty? ? "https://www.howtoedibles.com/" : "https://www.howtoedibles.com/#{page}"
    xhtml_links << %(    <xhtml:link rel="alternate" hreflang="x-default" href="#{xdef_href}" />)

    ALL_LANGS.each do |l|
      lang_seg = l == "en" ? nil : l
      path = [lang_seg, page.empty? ? nil : page].compact.join("/")
      loc = if path.empty?
        "https://www.howtoedibles.com/"
      elsif page.empty?
        "https://www.howtoedibles.com/#{path}/"
      else
        "https://www.howtoedibles.com/#{path}"
      end
      urls << "  <url>\n    <loc>#{loc}</loc>\n    <lastmod>2026-06-25</lastmod>\n#{xhtml_links.join("\n")}\n  </url>"
    end
  end

  # Article pages (with hreflang for translated versions)
  article_files = Dir.glob(File.join(ROOT_DIR, "*.html")).map { |f| File.basename(f) }
  article_files -= %w[index.html calculator.html donate.html 404.html articles.html]
  article_files.sort.each do |f|
    slug = f.sub(/\.html$/, "")
    # Check which languages have this article translated
    available_langs = ["en"] + LANGS.select { |l| (a = ARTICLE_I18N.dig(l, "articles", slug)) && !a["raw_main"] }
    if available_langs.size > 1
      xhtml_links = available_langs.map do |l|
        prefix = lang_prefix(l)
        href = "https://www.howtoedibles.com#{prefix}/#{f}"
        html_lang = lang_html(l)
        %(    <xhtml:link rel="alternate" hreflang="#{html_lang}" href="#{href}" />)
      end
      xhtml_links << %(    <xhtml:link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/#{f}" />)
      available_langs.each do |l|
        prefix = lang_prefix(l)
        loc = "https://www.howtoedibles.com#{prefix}/#{f}"
        urls << "  <url>\n    <loc>#{loc}</loc>\n    <lastmod>2026-06-25</lastmod>\n#{xhtml_links.join("\n")}\n  </url>"
      end
    else
      urls << "  <url>\n    <loc>https://www.howtoedibles.com/#{f}</loc>\n    <lastmod>2026-06-25</lastmod>\n  </url>"
    end
  end

  # Recipe and category pages (all 5 languages each)
  pages = RECIPES.map { |r| ["recipes/#{r["slug"]}/", "2026-03-15"] } +
          CAT_ORDER.map { |c| ["category/#{CAT_BY_NAME[c]["slug"]}/", "2026-11-09"] }
  pages.each do |path, lastmod|
    xhtml_links = ALL_LANGS.map do |l|
      %(    <xhtml:link rel="alternate" hreflang="#{lang_html(l)}" href="https://www.howtoedibles.com#{lang_prefix(l)}/#{path}" />)
    end
    xhtml_links << %(    <xhtml:link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/#{path}" />)

    ALL_LANGS.each do |l|
      loc = "https://www.howtoedibles.com#{lang_prefix(l)}/#{path}"
      urls << "  <url>\n    <loc>#{loc}</loc>\n    <lastmod>#{lastmod}</lastmod>\n#{xhtml_links.join("\n")}\n  </url>"
    end
  end

  sitemap = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
            xmlns:xhtml="http://www.w3.org/1999/xhtml">
    #{urls.join("\n")}
    </urlset>
  XML

  sitemap = real_lastmods(sitemap)
  write_file(File.join(ROOT_DIR, "sitemap.xml"), sitemap)
  puts "  sitemap.xml (#{urls.count} URLs)"
end

# lastmod = the day a page's <main> last changed (#90), so a menu or footer tweak doesn't touch every URL.
# data/lastmod.json keeps { url => [hash of <main>, date] }; a URL seen for the first time gets the build date.
LASTMOD_FILE = File.join(ROOT_DIR, "data", "lastmod.json")

def real_lastmods(sitemap)
  old = File.exist?(LASTMOD_FILE) ? JSON.parse(File.read(LASTMOD_FILE)) : {}
  seen = {}
  out = sitemap.gsub(%r{<loc>([^<]+)</loc>\n    <lastmod>[^<]*</lastmod>}) do
    raw = $1
    loc = raw.sub(%r{\A#{SITE}/calculator\.html\z}, "#{SITE}#{EN_CALC}") # write_file moves it there
    path = loc.delete_prefix("#{SITE}/")
    file = File.join(ROOT_DIR, path.empty? || path.end_with?("/") ? "#{path}index.html" : path)
    html = File.read(file)
    main = html[%r{<main\b.*</main>}m] or abort "ERROR: #{file} (in the sitemap) has no <main>"
    hash = Digest::SHA1.hexdigest(main)
    seen[loc] = old[loc] && old[loc][0] == hash ? old[loc] : [hash, Date.today.iso8601]
    # The Recipe JSON-LD's dateModified is the same day (it sits in <head>, so it doesn't move the hash)
    if path.match?(%r{\A(?:[a-z]{2}/)?recipes/})
      fixed = html.sub(/"dateModified":"[^"]*"/, %("dateModified":"#{seen[loc][1]}"))
      File.write(file, fixed) unless fixed == html
    end
    "<loc>#{raw}</loc>\n    <lastmod>#{seen[loc][1]}</lastmod>"
  end
  File.write(LASTMOD_FILE, JSON.pretty_generate(seen.sort.to_h) + "\n")
  out
end

require_relative "build_redesign" # the shell and every page template

# ═════════════════════════════════════════════
# BUILD
# ═════════════════════════════════════════════

# Special pages (#74) and articles for every language. The root /404.html is one file for all 5.
ALL_LANGS.each do |lang|
  puts "\nBuilding #{lang.upcase}..."
  build_home(lang)
  build_calc_page(lang)
  build_donate(lang)
  build_articles_index(lang)
  puts "  #{lang_prefix(lang)}/ index, calculator, donate, articles"

  slugs = (ARTICLE_I18N.dig(lang, "articles") || {}).keys.sort
  slugs.each { |slug| build_article_page(slug, lang) }
  puts "  #{lang_prefix(lang)}/ articles (#{slugs.size} pages)"
end
build_root_404
puts "  /404.html (all languages)"
%w[about.html contact.html].each { |f| build_kept(f) }
puts "  /about.html, /contact.html (English only; body kept, shell rebuilt)"

# Recipe pages, category pages and search indexes for ALL languages, on the new shell (scripts/build_redesign.rb)
puts "\nBuilding recipe and category pages for all languages..."
RECIPE_LANGS.each do |lang|
  RECIPES.each { |recipe| build_recipe_page(recipe, lang) }
  CAT_ORDER.each { |cat| build_category_page(cat, lang) }
  build_search_index(lang)
  puts "  #{lang_prefix(lang)}/recipes/ (#{RECIPES.count}), #{lang_prefix(lang)}/category/ (#{CAT_ORDER.size}), data/search-#{lang}.json"
end

puts "\nBuilding sitemap..."
build_sitemap
check_inbound_links

puts "\nRendering og/schema rasters..."
render_rasters

puts "\nDone! Hand-maintained: the bodies of about.html and contact.html (English only)."

puts
exit 1 unless system("ruby", File.join(__dir__, "check_budget.rb"))
