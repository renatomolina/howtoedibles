#!/usr/bin/env ruby
# scripts/build_site.rb
# Generates every page except the hand-maintained English about and contact (see CLAUDE.md).
#
# Run: ruby scripts/build_site.rb

require "json"
require "fileutils"
require "cgi"
require "zlib"
require "date"

ROOT_DIR   = File.expand_path("..", __dir__)
DATA_FILE  = File.join(ROOT_DIR, "data", "recipes.json")
I18N_DIR   = File.join(ROOT_DIR, "i18n")
IMAGE_BASE = "/images/recipes"

abort "ERROR: #{DATA_FILE} not found." unless File.exist?(DATA_FILE)

data       = JSON.parse(File.read(DATA_FILE))
CATEGORIES = data["categories"]
RECIPES    = data["recipes"]

# ─────────────────────────────────────────────
# i18n Loading
# ─────────────────────────────────────────────

LANGS = %w[pt es de zh]  # non-English only — English is hand-maintained
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

# Load per-recipe unique sentence translations
RECIPE_I18N["en"] = {} # English recipes use data directly from recipes.json

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

def extract_list_items(html_str)
  return [] unless html_str.is_a?(String)
  # Plain text for JSON-LD: strip tags and decode entities (&frac12;, &nbsp;, ...).
  html_str.scan(/<li[^>]*>(.*?)<\/li>/m).map { |m| decode_entities(m[0].gsub(/<[^>]+>/, "")).strip }
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

def write_file(path, content)
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

# ─────────────────────────────────────────────
# Shared HTML Components (matching English site exactly)
# ─────────────────────────────────────────────

def build_head(lang, title:, description:, canonical:, keywords: nil, structured_data: nil, extra_head: "",
               og_type: "website", og_title: title, langs: ALL_LANGS, source: "data/ and i18n/")
  html_lang = lang_html(lang)
  prefix = lang_prefix(lang)
  # Extract language-neutral page path for hreflang
  page_path = canonical.sub("https://www.howtoedibles.com", "").sub(/^\//, "")
  page_path = page_path.sub(%r{^(pt|es|de|zh)/}, "")

  kw = keywords

  sd_block = if structured_data && !structured_data.empty?
    "\n  <!-- Structured Data -->\n  <script type=\"application/ld+json\">\n#{structured_data}\n</script>"
  else
    "\n  <!-- Structured Data -->\n  "
  end

  <<~HTML
    <!DOCTYPE html>
    <!-- Generated by scripts/build_site.rb from #{source} — edit the source, not this file -->
    <html lang="#{html_lang}">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
      <title>#{h(title)}</title>
      <meta name="description" content="#{h(description)}" />
      <link rel="canonical" href="#{canonical}" />
      <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />

      <!-- Open Graph -->
      <meta property="og:type" content="#{og_type}" />
      <meta property="og:site_name" content="HowToEdibles" />
      <meta property="og:title" content="#{h(og_title)}" />
      <meta property="og:description" content="#{h(description)}" />
      <meta property="og:image" content="https://www.howtoedibles.com/images/brand/og-image.jpg" />
      <meta property="og:url" content="#{canonical}" />

      <!-- Twitter -->
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content="#{h(og_title)}" />
      <meta name="twitter:description" content="#{h(description)}" />
      <meta name="twitter:image" content="https://www.howtoedibles.com/images/brand/og-image.jpg" />

      #{kw ? %(<meta name="keywords" content="#{h(kw)}" />) : ""}
      <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />

      <!-- hreflang -->
      #{hreflang_tags(page_path, langs)}
    #{sd_block}

      <!-- Bootstrap 4 -->
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" crossorigin="anonymous" />
      <!-- Font Awesome -->
      <link rel="preload" as="style" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" onload="this.rel='stylesheet'" />
      <noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /></noscript>
      <!-- Site CSS -->
      <link rel="stylesheet" href="/css/styles.css" />
      <script>try{if(localStorage.getItem("theme")==="dark")document.documentElement.setAttribute("data-theme","dark")}catch(e){}</script>
      <!-- AdSense -->
      <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6354522716906819" crossorigin="anonymous"></script>

    #{extra_head}
    </head>
  HTML
end

def build_navbar(lang)
  prefix = lang_prefix(lang)
  search_placeholder = t(lang, "navbar", "search_placeholder")
  calculator_label = t(lang, "navbar", "calculator")

  # Build category dropdowns with translated recipe names
  cats_by_name = {}
  CATEGORIES.each { |c| cats_by_name[c["name"]] = c }

  category_order = %w[Desserts Drinks Snacks Essentials Lunch Keto Vegan International]

  dropdowns = category_order.map do |cat_name|
    cat = cats_by_name[cat_name]
    next unless cat
    cat_recipes = RECIPES.select { |r| r["category_name"] == cat_name }
    next if cat_recipes.empty?

    translated_cat = category_t(lang, cat_name)
    items = cat_recipes.map do |r|
      name = recipe_t(lang, r["slug"], "name") || r["name"]
      %(<a class="dropdown-item" href="#{prefix}/recipes/#{r["slug"]}/">#{h(name)}</a>)
    end.join("\n            ")

    <<~DD
          <li class="nav-item dropdown">
            <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">#{h(translated_cat)}</a>
            <div class="dropdown-menu shadow-sm" role="menu">
                #{items}
            </div>
          </li>
    DD
  end.compact.join("")

  # Language switcher
  lang_switcher = build_language_switcher(lang)

  <<~HTML
      <body>
        <nav class="navbar navbar-expand-lg navbar-light">
      <div class="container">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarMain" aria-expanded="false" aria-label="Toggle navigation">
          <span class="fa fa-bars navbar-icon"></span>
        </button>
        <a href="#{prefix}/" class="navbar-brand logo-link">
          <img src="/images/howtoedibleslogo.png" alt="How to Edibles" width="180" height="65" />
        </a>
        <div class="collapse navbar-collapse" id="navbarMain">
          <ul class="navbar-nav ml-auto align-items-lg-center">
            <li class="nav-item mr-lg-2">
              <a href="#{prefix}/calculator.html" class="btn btn-nav-calculator">#{h(calculator_label)}</a>
            </li>
            <li class="nav-item">
              <button id="dark-mode-toggle" class="dark-mode-toggle" aria-label="Toggle dark mode"><i class="fa fa-moon"></i><i class="fa fa-sun"></i></button>
            </li>
    #{dropdowns}#{lang_switcher}      </ul>
        </div>
      </div>
    </nav>

    <div class="site-search-bar">
      <div class="container">
        <i class="fa fa-search site-search-icon"></i>
        <input type="search" id="recipe-search" class="site-search-input" placeholder="#{h(search_placeholder)}" autocomplete="off" />
      </div>
    </div>

  HTML
end

def build_language_switcher(lang)
  labels = { "en" => "EN", "pt" => "PT", "es" => "ES", "de" => "DE", "zh" => "中文" }
  names = { "en" => "English", "pt" => "Portugues", "es" => "Espanol", "de" => "Deutsch", "zh" => "中文" }
  current_label = labels[lang] || lang.upcase

  items = ALL_LANGS.map do |l|
    lprefix = lang_prefix(l)
    active = l == lang ? " active" : ""
    %(<a class="dropdown-item lang-item#{active}" href="#{lprefix}/">#{names[l]}</a>)
  end.join("\n          ")

  <<~HTML
        <li class="nav-item dropdown lang-dropdown ml-lg-2">
          <a href="#" class="nav-link lang-toggle dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-globe"></i> #{current_label}</a>
          <div class="dropdown-menu dropdown-menu-right shadow-sm" role="menu">
            #{items}
          </div>
        </li>
  HTML
end

def build_footer(lang)
  prefix = lang_prefix(lang)

  tagline = t(lang, "footer", "tagline")
  recipes_title = t(lang, "footer", "recipes_title")
  all_recipes = t(lang, "footer", "all_recipes")
  calculator = t(lang, "footer", "calculator")
  learn_title = t(lang, "footer", "learn_title")
  articles_label = t(lang, "articles", "title")
  how_calc = t(lang, "footer", "how_calculator")
  prevent_trip = t(lang, "footer", "prevent_bad_trip")
  bad_trip_chat = t(lang, "footer", "bad_trip_chat")
  support_us = t(lang, "footer", "support_us")
  tip_title = t(lang, "footer", "dosage_tip_title")
  tip_text = t(lang, "footer", "dosage_tip")
  copyright = t(lang, "footer", "copyright")

  # Language switcher links
  lang_links = ALL_LANGS.map do |l|
    lname = I18N[l]["lang_name"] || l.upcase
    lflag = I18N[l]["lang_flag"] || ""
    lprefix = lang_prefix(l)
    if l == lang
      %(<span class="footer-lang-current">#{lflag} #{lname}</span>)
    else
      %(<a href="#{lprefix}/" class="footer-lang-link">#{lflag} #{lname}</a>)
    end
  end.join(" · ")

  <<~HTML
        <footer class="site-footer mt-auto">
      <div class="container">
        <div class="row footer-main">
          <div class="col-lg-4 col-md-6 mb-4 mb-md-0">
            <a href="#{prefix}/" class="footer-brand">
              <img src="/images/howtoedibleslogo.png" alt="How to Edibles" />
            </a>
            <p class="footer-tagline mt-3">#{h(tagline)}</p>
            <div class="footer-social mt-3">
              <a href="https://instagram.com/howtoedibles" target="_blank" rel="noopener noreferrer" class="footer-social-link" aria-label="Instagram">
                <i class="fa-brands fa-instagram"></i>
              </a>
              <a href="https://facebook.com/howtoedibles" target="_blank" rel="noopener noreferrer" class="footer-social-link" aria-label="Facebook">
                <i class="fa-brands fa-facebook"></i>
              </a>
            </div>
          </div>
          <div class="col-lg-2 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">#{h(recipes_title)}</h5>
            <ul class="footer-links">
              <li><a href="#{prefix}/">#{h(all_recipes)}</a></li>
              <li><a href="#{prefix}/calculator.html">#{h(calculator)}</a></li>
            </ul>
          </div>
          <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">#{h(learn_title)}</h5>
            <ul class="footer-links">
              <li><a href="#{prefix}/articles.html">#{h(articles_label)}</a></li>
              <li><a href="#{prefix}/how-a-cannabis-calculator-works.html">#{h(how_calc)}</a></li>
              <li><a href="#{prefix}/how-to-prevent-a-bad-trip.html">#{h(prevent_trip)}</a></li>
              <li><a href="https://bit.ly/helpimhavingabadtrip" target="_blank" rel="noopener noreferrer">#{h(bad_trip_chat)}</a></li>
              <li><a href="#{prefix}/donate.html">#{h(support_us)}</a></li>
              <li><a href="/about.html">#{h(t(lang, "footer", "about_us"))}</a></li>
            </ul>
          </div>
          <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">#{h(tip_title)}</h5>
            <p class="footer-tip"><i class="fa fa-leaf orange mr-2"></i>#{h(tip_text)}</p>
            <div class="footer-lang-switcher mt-3">
              #{lang_links}
            </div>
          </div>
        </div>
        <div class="footer-bottom">
          <p>&copy; 2026 HowToEdibles &mdash; #{h(copyright)}</p>
        </div>
      </div>
    </footer>
  HTML
end

def build_scripts(lang, extra_scripts: "")
  prefix = lang_prefix(lang)

  <<~HTML

        <!-- Google tag (gtag.js) -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-MGB628XR50"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-MGB628XR50');
    </script>


        <script src="/js/search-autocomplete.js"></script>
        <!-- jQuery + Bootstrap 4 bundle -->
        <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
        <script src="/js/mobile-menu.js"></script>
        <!-- Search redirect for non-homepage pages -->
        <script>
          (function(){
            var inp = document.getElementById('recipe-search');
            if (!inp || document.getElementById('pagination-controls')) return;
            inp.addEventListener('keydown', function(e){
              if (e.key === 'Enter') { e.preventDefault(); var q = inp.value.trim(); if (q) window.location.href = '#{prefix}/?search=' + encodeURIComponent(q); }
            });
          })();
        </script>
    #{extra_scripts}
          <script src="/js/dark-mode.js"></script>
      </body>
    </html>
  HTML
end

COOKING_EFFICIENCY = 0.80  # must match COOKING_EFFICIENCY in js/calculator.js

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

def build_recipe_faq_schema(recipe, lang)
  slug = recipe["slug"]
  enrich = ENRICHMENT[slug] || {}
  name = recipe_t(lang, slug, "name") || recipe["name"]
  category = recipe["category_name"]
  sub_cat = enrich["sub_category"] || "general"
  base_fat = enrich["base_fat"] || "cannabutter"

  tmpl = get_recipe_section_template(lang, category, sub_cat)
  vars = { "name" => name, "base_fat" => base_fat, "cook_temp" => enrich["cook_temp"] || "350°F / 180°C", "category" => category }

  faqs = tmpl["faq"] || []
  return nil if faqs.empty?

  {
    "@context" => "https://schema.org",
    "@type" => "FAQPage",
    "mainEntity" => faqs.map do |faq|
      {
        "@type" => "Question",
        "name" => interpolate(faq["q"], vars),
        "acceptedAnswer" => {
          "@type" => "Answer",
          "text" => interpolate(faq["a"], vars)
        }
      }
    end
  }
end

# ─────────────────────────────────────────────
# Recipe pages
# ─────────────────────────────────────────────

FLOWER_AMOUNT_RE = /(\d+(?:[.,]\d+)?)(\s*(?:gramas?\b|gramos?\b|Gramm\b|g\b|克))?(\s*(?:de\s+)?)(ground\s*weed|maconha triturada|erva moída|cannabis moída|marihuana molida|hierba molida|cannabis molida|gemahlenes Gras|gemahlenes Cannabis|研磨好的大麻|研磨大麻)/i

# ─────────────────────────────────────────────
# Individual article pages
# ─────────────────────────────────────────────

def build_article_page(slug, lang)
  prefix = lang_prefix(lang)
  ai = ARTICLE_I18N.dig(lang, "articles_index") || {}
  a = ARTICLE_I18N.dig(lang, "articles", slug)
  return unless a

  title = a["title"] || slug
  description = a["description"] || ""
  keywords = a["keywords"] || ""
  category = a["category"] || ""
  excerpt = a["excerpt"] || ""
  date_pub = a["date_published"] || "2026-03-05"
  date_mod = a["date_modified"] || date_pub
  read_time = a["read_time"] || ""
  toc = a["toc"] || []
  body_html = a["body_html"] || ""
  faq = a["faq"] || []
  related = a["related"] || []

  canonical = "https://www.howtoedibles.com#{prefix}/#{slug}.html"
  page_title = "#{title} | HowToEdibles"
  langs = ALL_LANGS.select { |l| ARTICLE_I18N.dig(l, "articles", slug) }

  # Frozen orphan page (#71): body and JSON-LD verbatim, only the shell is generated.
  # ponytail: temporary until the traffic map decides translate / noindex / remove.
  if a["raw_main"]
    page = build_head(lang, title: page_title, description: description, canonical: canonical, keywords: a["keywords"],
                      structured_data: JSON.generate(a["schema"]), og_type: "article", og_title: title, langs: langs,
                      source: "i18n/articles_#{lang}.json (frozen raw_main)")
    page << build_navbar(lang) << a["raw_main"] << "\n" << build_footer(lang) << build_scripts(lang)
    return write_file(output_path(lang, "#{slug}.html"), page)
  end

  # Structured data
  article_sd = {
    "@context" => "https://schema.org",
    "@type" => "Article",
    "headline" => title,
    "description" => description,
    "datePublished" => date_pub,
    "dateModified" => date_mod,
    "author" => { "@type" => "Organization", "name" => "HowToEdibles Editorial Team", "url" => "https://www.howtoedibles.com/about.html" },
    "publisher" => { "@type" => "Organization", "name" => "HowToEdibles", "url" => "https://www.howtoedibles.com",
                     "logo" => { "@type" => "ImageObject", "url" => "https://www.howtoedibles.com/images/brand/logo.png" } },
    "mainEntityOfPage" => { "@type" => "WebPage", "@id" => canonical }
  }

  breadcrumb_sd = {
    "@context" => "https://schema.org",
    "@type" => "BreadcrumbList",
    "itemListElement" => [
      { "@type" => "ListItem", "position" => 1, "name" => ai["breadcrumb_home"] || "Home", "item" => "https://www.howtoedibles.com#{prefix}/" },
      { "@type" => "ListItem", "position" => 2, "name" => ai["breadcrumb_articles"] || "Articles", "item" => "https://www.howtoedibles.com#{prefix}/articles.html" },
      { "@type" => "ListItem", "position" => 3, "name" => title, "item" => canonical }
    ]
  }

  sd_parts = [article_sd, breadcrumb_sd, *a["schema_extra"]]

  if faq && !faq.empty?
    faq_sd = {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => faq.map do |f|
        {
          "@type" => "Question",
          "name" => f["question"],
          "acceptedAnswer" => { "@type" => "Answer", "text" => f["answer"] }
        }
      end
    }
    sd_parts << faq_sd
  end

  structured_data = JSON.generate(sd_parts)

  # Build TOC
  toc_html = ""
  unless toc.empty?
    toc_items = toc.map { |t_item| %(<li><a href="##{t_item["id"]}">#{h(t_item["text"])}</a></li>) }.join("\n              ")
    toc_html = <<~TOC
      <div class="article-toc">
        <h4>#{h(ai["toc_title"] || "Table of Contents")}</h4>
        <ul>
              #{toc_items}
        </ul>
      </div>
    TOC
  end

  # Related articles (only ones that exist in this language)
  related = related.select { |r| ARTICLE_I18N.dig(lang, "articles", r["slug"]) }
  related_html = ""
  unless related.empty?
    related_cards = related.map do |r|
      desc = r["description"] ? %(\n              <p class="card-text">#{h(r["description"])}</p>) : ""
      <<~RC
        <div class="col-md-4 mb-3">
          <div class="card h-100">
            <div class="card-body">
              <h5 class="card-title"><a href="#{prefix}/#{r["slug"]}.html">#{h(r["title"])}</a></h5>#{desc}
            </div>
          </div>
        </div>
      RC
    end.join("")

    related_html = <<~REL
      <div class="related-articles mt-4 mb-5">
        <h3>#{h(ai["related_title"] || "Related Articles")}</h3>
        <div class="row">
          #{related_cards}
        </div>
      </div>
    REL
  end

  # Prefix internal links in body_html, but only to pages that exist in this
  # language — otherwise keep the English URL rather than link to a 404.
  prefixed_body = body_html.gsub(/href="\/([^"\/]+)\.html(#[^"]*)?"/) do |match|
    page_slug, anchor = $1, $2
    exists = ARTICLE_I18N.dig(lang, "articles", page_slug) || %w[calculator donate articles].include?(page_slug)
    exists ? %(href="#{prefix}/#{page_slug}.html#{anchor}") : match
  end
  prefixed_body = prefixed_body.include?("<!-- toc -->") ? prefixed_body.sub("<!-- toc -->", toc_html) : toc_html + prefixed_body

  date_fmt = ->(d) { lang == "en" ? Date.parse(d).strftime("%B %-d, %Y") : d }
  updated = a["show_updated"] ? %(<span><i class="fa fa-sync"></i> #{h(ai["updated"] || "Updated")} #{date_fmt.(date_mod)}</span>) : ""

  page = build_head(lang, title: page_title, description: description, canonical: canonical, keywords: keywords,
                    structured_data: structured_data, og_type: "article", og_title: title, langs: langs,
                    source: "i18n/articles_#{lang}.json")
  page << build_navbar(lang)
  page << <<~HTML
    <section class="article-hero">
      <div class="container">
        <span class="article-category">#{h(category)}</span>
        <h1>#{h(a["h1"] || title)}</h1>
        <div class="article-meta">
          <span><i class="fa fa-user"></i> #{h(ai["byline"] || "By")} <a href="/about.html">HowToEdibles Editorial Team</a></span>
          <span><i class="fa fa-calendar"></i> #{date_fmt.(date_pub)}</span>#{updated}
          <span><i class="fa fa-clock"></i> #{h(read_time)}</span>
        </div>
        <p class="article-excerpt">#{h(excerpt)}</p>
      </div>
    </section>

    <div class="article-breadcrumbs">
      <div class="container">
        <a href="#{prefix}/">#{h(ai["breadcrumb_home"] || "Home")}</a>
        <span class="separator">/</span>
        <a href="#{prefix}/articles.html">#{h(ai["breadcrumb_articles"] || "Articles")}</a>
        <span class="separator">/</span>
        #{h(title)}
      </div>
    </div>

    <article class="article-body">
      <div class="container">
        <div class="row">
          <div class="col-lg-8 offset-lg-2">

            #{prefixed_body}

            <div class="text-center mt-5 mb-5">
              <a href="#{prefix}/articles.html" class="btn btn-success btn-lg">#{h(ai["read_more_articles"] || "Read more articles")}</a>
            </div>

            #{related_html}

          </div>
        </div>
      </div>
    </article>
  HTML
  page << build_footer(lang)
  page << build_scripts(lang)
  write_file(output_path(lang, "#{slug}.html"), page)
end

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

  write_file(File.join(ROOT_DIR, "sitemap.xml"), sitemap)
  puts "  sitemap.xml (#{urls.count} URLs)"
end

require_relative "build_redesign" # the new shell + recipe/category templates

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
build_about
puts "  /about.html (English only; body kept, shell rebuilt)"

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

puts "\nDone! Hand-maintained: the about.html body and contact.html (English only)."

puts
exit 1 unless system("ruby", File.join(__dir__, "check_budget.rb"))
