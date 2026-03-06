#!/usr/bin/env ruby
# scripts/build_site.rb
# Standalone i18n-aware build script — no Rails required.
# Run: ruby scripts/build_site.rb
#
# Reads data/recipes.json and i18n/*.json, generates all HTML pages
# in English (root) + /pt/, /es/, /de/ subdirectories.

require "json"
require "fileutils"
require "cgi"

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

LANGS = %w[en pt es de]

I18N = {}
LANGS.each do |lang|
  path = File.join(I18N_DIR, "#{lang}.json")
  if File.exist?(path)
    I18N[lang] = JSON.parse(File.read(path))
  else
    warn "WARNING: #{path} not found, using English fallback for '#{lang}'"
    I18N[lang] = {}
  end
end

# Recipe translations
RECIPE_I18N = {}
LANGS.each do |lang|
  next if lang == "en"
  path = File.join(I18N_DIR, "recipes_#{lang}.json")
  if File.exist?(path)
    RECIPE_I18N[lang] = JSON.parse(File.read(path))
  else
    warn "WARNING: #{path} not found, recipes will use English for '#{lang}'"
    RECIPE_I18N[lang] = {}
  end
end

puts "Building site from #{RECIPES.count} recipes across #{CATEGORIES.count} categories in #{LANGS.count} languages..."

# ─────────────────────────────────────────────
# Translation Helpers
# ─────────────────────────────────────────────

def t(lang, *keys)
  val = I18N[lang]
  keys.each do |key|
    val = val.is_a?(Hash) ? val[key] : nil
    break if val.nil?
  end
  # Fallback to English
  if val.nil? && lang != "en"
    val = I18N["en"]
    keys.each do |key|
      val = val.is_a?(Hash) ? val[key] : nil
      break if val.nil?
    end
  end
  val
end

def lang_prefix(lang)
  lang == "en" ? "" : "/#{lang}"
end

def recipe_t(lang, slug, field)
  return nil if lang == "en"
  tr = RECIPE_I18N.dig(lang, slug)
  tr ? tr[field] : nil
end

def translate_category(lang, english_name)
  t(lang, "categories", english_name) || english_name
end

# ─────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────

SITE_URL  = "https://www.howtoedibles.com"
GA_ID = "UA-90858722-1"
ADSENSE_PUBLISHER = "ca-pub-6354522716906819"
SLOT_LEADERBOARD  = "4353785890"
SLOT_MEDIUM       = "5475295879"

# Strip HTML tags and return array of plain-text list items
def extract_li_texts(html)
  html.scan(/<li[^>]*>(.*?)<\/li>/mi).map { |m| m[0].gsub(/<[^>]+>/, "").strip }.reject(&:empty?)
end

def adsense_loader_script
  <<~HTML
    <script>
      function downloadJSAtOnload() {
        var el = document.createElement("script");
        el.src = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=#{ADSENSE_PUBLISHER}";
        el.async = true;
        el.setAttribute('crossorigin', 'anonymous');
        document.body.appendChild(el);
      }
      if (window.addEventListener)
        window.addEventListener("load", downloadJSAtOnload, false);
      else if (window.attachEvent)
        window.attachEvent("onload", downloadJSAtOnload);
      else window.onload = downloadJSAtOnload;
    </script>
  HTML
end

def analytics_script
  <<~HTML
    <!-- Google tag (gtag.js) -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=#{GA_ID}"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', '#{GA_ID}');
    </script>
  HTML
end

# ─────────────────────────────────────────────
# Hreflang Tags
# ─────────────────────────────────────────────

def hreflang_tags(page_path)
  tags = LANGS.map do |l|
    prefix = lang_prefix(l)
    href = "#{SITE_URL}#{prefix}#{page_path}"
    hreflang = l == "en" ? "en" : (l == "pt" ? "pt-BR" : l)
    "  <link rel=\"alternate\" hreflang=\"#{hreflang}\" href=\"#{href}\" />"
  end
  tags << "  <link rel=\"alternate\" hreflang=\"x-default\" href=\"#{SITE_URL}#{page_path}\" />"
  tags.join("\n")
end

# ─────────────────────────────────────────────
# HTML Components
# ─────────────────────────────────────────────

def html_head(lang:, title:, description:, canonical:, page_path:, og_image: "#{SITE_URL}/images/pot-brownies.jpg",
              og_type: "website", schema_json: nil, keywords: nil)
  default_keywords = "edible dosage calculator, cannabis edibles, how much weed for edibles, THC calculator, edible potency, marijuana edibles, cannabis dosage, weed edibles"
  kw = keywords ? "#{keywords}, #{default_keywords}" : default_keywords
  schema_tag = schema_json ? "<script type=\"application/ld+json\">\n#{schema_json}\n</script>" : ""
  html_lang = lang == "pt" ? "pt-BR" : lang
  <<~HTML
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
      <title>#{CGI.escapeHTML(title)}</title>
      <meta name="description" content="#{CGI.escapeHTML(description)}" />
      <link rel="canonical" href="#{canonical}" />
      <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />

      <!-- Hreflang -->
    #{hreflang_tags(page_path)}

      <!-- Open Graph -->
      <meta property="og:type" content="#{og_type}" />
      <meta property="og:site_name" content="HowToEdibles" />
      <meta property="og:title" content="#{CGI.escapeHTML(title)}" />
      <meta property="og:description" content="#{CGI.escapeHTML(description)}" />
      <meta property="og:image" content="#{og_image}" />
      <meta property="og:url" content="#{canonical}" />
      <meta property="og:locale" content="#{html_lang.tr("-", "_")}" />

      <!-- Twitter -->
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content="#{CGI.escapeHTML(title)}" />
      <meta name="twitter:description" content="#{CGI.escapeHTML(description)}" />
      <meta name="twitter:image" content="#{og_image}" />

      <meta name="keywords" content="#{CGI.escapeHTML(kw)}" />
      <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />

      <!-- Structured Data -->
      #{schema_tag}

      <!-- Bootstrap 4 -->
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" crossorigin="anonymous" />
      <!-- Font Awesome -->
      <link rel="preload" as="style" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" onload="this.rel='stylesheet'" />
      <noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /></noscript>
      <!-- Site CSS -->
      <link rel="stylesheet" href="/css/styles.css" />

      #{adsense_loader_script}
    </head>
  HTML
end

def html_language_switcher(lang, page_path)
  current_name = t(lang, "lang_name") || lang.upcase
  links = LANGS.map do |l|
    prefix = lang_prefix(l)
    name = t(l, "lang_name") || l.upcase
    active = l == lang ? " active" : ""
    "              <a class=\"dropdown-item lang-item#{active}\" href=\"#{prefix}#{page_path}\">#{name}</a>"
  end.join("\n")

  <<~HTML.chomp
        <li class="nav-item dropdown lang-dropdown">
          <a href="#" class="nav-link dropdown-toggle lang-toggle" data-toggle="dropdown" aria-label="#{t(lang, "language_switcher", "label") || "Language"}">
            <i class="fa fa-globe mr-1"></i> #{current_name}
          </a>
          <div class="dropdown-menu dropdown-menu-right shadow-sm">
  #{links}
          </div>
        </li>
  HTML
end

def html_navbar(lang, page_path)
  prefix = lang_prefix(lang)

  dropdown_items = CATEGORIES.map do |cat|
    cat_name = translate_category(lang, cat["name"])
    recipe_links = cat["recipes"].map do |r|
      r_name = recipe_t(lang, r["slug"], "name") || r["name"]
      "            <a class=\"dropdown-item\" href=\"#{prefix}/recipes/#{r["slug"]}/\">#{CGI.escapeHTML(r_name)}</a>"
    end.join("\n")

    <<~HTML.chomp
          <li class="nav-item dropdown">
            <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">#{CGI.escapeHTML(cat_name)}</a>
            <div class="dropdown-menu shadow-sm" role="menu">
    #{recipe_links}
            </div>
          </li>
    HTML
  end.join("\n")

  search_placeholder = t(lang, "navbar", "search_placeholder") || "Search recipes…"
  calculator_label = t(lang, "navbar", "calculator") || "Calculator"

  <<~HTML
    <nav class="navbar navbar-expand-lg navbar-light">
      <div class="container">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarMain" aria-expanded="false" aria-label="Toggle navigation">
          <span class="fa fa-bars navbar-icon"></span>
        </button>
        <a href="#{prefix}/" class="navbar-brand logo-link">
          <img src="/images/howtoedibleslogo.png" alt="How to Edibles" width="180" height="65" />
        </a>
        <!-- Search — always visible, outside collapse -->
        <div class="nav-search-wrapper mx-2">
          <i class="fa fa-search nav-search-icon"></i>
          <input type="search" id="recipe-search" class="nav-search-input" placeholder="#{CGI.escapeHTML(search_placeholder)}" autocomplete="off" />
        </div>
        <div class="collapse navbar-collapse" id="navbarMain">
          <ul class="navbar-nav ml-auto align-items-lg-center">
            <li class="nav-item mr-lg-2">
              <a href="#{prefix}/calculator.html" class="btn btn-nav-calculator">#{CGI.escapeHTML(calculator_label)}</a>
            </li>
    #{dropdown_items}
    #{html_language_switcher(lang, page_path)}
          </ul>
        </div>
      </div>
    </nav>
  HTML
end

def html_footer(lang)
  prefix = lang_prefix(lang)
  <<~HTML
    <footer class="site-footer mt-auto">
      <div class="container">
        <div class="row footer-main">
          <div class="col-lg-4 col-md-6 mb-4 mb-md-0">
            <a href="#{prefix}/" class="footer-brand">
              <img src="/images/howtoedibleslogo.png" alt="How to Edibles" />
            </a>
            <p class="footer-tagline mt-3">#{t(lang, "footer", "tagline") || "Cannabis edibles made easy. Recipes, dosing calculator, and harm reduction tips."}</p>
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
            <h5 class="footer-col-title">#{t(lang, "footer", "recipes_title") || "Recipes"}</h5>
            <ul class="footer-links">
              <li><a href="#{prefix}/">#{t(lang, "footer", "all_recipes") || "All recipes"}</a></li>
              <li><a href="#{prefix}/calculator.html">#{t(lang, "footer", "calculator") || "Calculator"}</a></li>
            </ul>
          </div>
          <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">#{t(lang, "footer", "learn_title") || "Learn"}</h5>
            <ul class="footer-links">
              <li><a href="#{prefix}/how-a-cannabis-calculator-works.html">#{t(lang, "footer", "how_calculator") || "How the calculator works"}</a></li>
              <li><a href="#{prefix}/how-to-prevent-a-bad-trip.html">#{t(lang, "footer", "prevent_bad_trip") || "How to prevent a bad trip"}</a></li>
              <li><a href="https://bit.ly/helpimhavingabadtrip" target="_blank" rel="noopener noreferrer">#{t(lang, "footer", "bad_trip_chat") || "Bad trip support chat"}</a></li>
              <li><a href="#{prefix}/donate.html">#{t(lang, "footer", "support_us") || "Support us"}</a></li>
            </ul>
          </div>
          <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">#{t(lang, "footer", "dosage_tip_title") || "Dosage tip"}</h5>
            <p class="footer-tip"><i class="fa fa-leaf orange mr-2"></i>#{t(lang, "footer", "dosage_tip") || "Start low, go slow. Wait at least 2 hours before taking more."}</p>
          </div>
        </div>
        <div class="footer-bottom">
          <p>&copy; #{Time.now.year} HowToEdibles &mdash; #{t(lang, "footer", "copyright") || "For educational purposes only. Always consume responsibly."}</p>
        </div>
      </div>
    </footer>
  HTML
end

def html_leaderboard_ad
  <<~HTML
    <div class="row d-none d-md-block text-center">
      <!-- Leaderboard -->
      <ins class="adsbygoogle"
           style="display:inline-block;width:750px;height:90px"
           data-ad-client="#{ADSENSE_PUBLISHER}"
           data-ad-slot="#{SLOT_LEADERBOARD}"></ins>
      <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
    </div>
  HTML
end

def html_medium_ad
  <<~HTML
    <div class="mt-2 mb-3 d-sm-none">
      <!-- Medium Rectangle -->
      <ins class="adsbygoogle"
           style="display:block"
           data-ad-client="#{ADSENSE_PUBLISHER}"
           data-ad-slot="#{SLOT_MEDIUM}"
           data-ad-format="auto"></ins>
      <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
    </div>
  HTML
end

def html_calculator_widget(lang, quantity:, portion:, potency:)
  <<~HTML
    <div id="calculator-widget">
      <div class="calculator-item pt-1">
        <div class="pb-1">
          <h3>#{t(lang, "calculator", "weed_quantity") || "How much weed do you have?"}</h3>
        </div>
        <input id="grams-slider" type="range"
               min="0.01" max="28" step="0.1" value="#{quantity}" />
        <div class="calculator-control mt-2 mb-3">
          <a href="#" id="decrease-quantity">
            <i class="fa fa-minus-circle fa-lg yellow" aria-hidden="true"></i>
          </a>
          <input id="grams-input" type="number" step="any" class="calculator-input mr-1 ml-1" onchange="updateQuantity(this.value)" />
          <span id="grams-quantity-label" class="mr-1"></span>
          <a href="#" id="increase-quantity">
            <i class="fa fa-plus-circle fa-lg green" aria-hidden="true"></i>
          </a>
        </div>
      </div>

      <div class="calculator-item-large pt-1">
        <h3>#{t(lang, "calculator", "weed_strength") || "How strong is your weed?"}</h3>
        <div class="average-tip mb-2">
          <span class="bottomtip">#{t(lang, "calculator", "average_tip") || "(14% average)"}</span>
          <a class="label-calculator ml-1 mb-1" data-toggle="modal" href="#" data-target="#myModal">
            <span class="badge badge-success">#{t(lang, "calculator", "not_sure") || "NOT SURE?"}</span>
          </a>
        </div>
        <input id="strength-slider" type="range"
               min="1" max="99" step="1" value="#{potency}" />

        <!-- Potency reference modal -->
        <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title" id="myModalLabel">#{t(lang, "calculator", "potency_modal_title") || "Reference for weed potency"}</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body">
                <table class="modal-potency-table table table-bordered">
                  <thead><tr><th>#{t(lang, "calculator", "potency_modal_weed_type") || "WEED TYPE"}</th><th>#{t(lang, "calculator", "potency_modal_potency") || "% (potency)"}</th></tr></thead>
                  <tbody>
                    <tr><td>#{t(lang, "calculator", "potency_low") || "Low quality"}</td><td>5%–10%</td></tr>
                    <tr><td>#{t(lang, "calculator", "potency_medium") || "Medium quality"}</td><td>10%–15%</td></tr>
                    <tr><td>#{t(lang, "calculator", "potency_high") || "Top Shelf"}</td><td>15%–40%</td></tr>
                    <tr><td>#{t(lang, "calculator", "potency_concentrates") || "Concentrates"}</td><td>35%–95%</td></tr>
                  </tbody>
                </table>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">#{t(lang, "calculator", "modal_close") || "Close"}</button>
              </div>
            </div>
          </div>
        </div>

        <div class="calculator-control mt-1 mb-3">
          <a href="#" id="decrease-strength">
            <i class="fa fa-minus-circle fa-lg yellow" aria-hidden="true"></i>
          </a>
          <input id="strength-input" type="number" step="any" class="calculator-input mr-1 ml-1" onchange="updateStrength(this.value)" /> % THC
          <a href="#" id="increase-strength" class="ml-1">
            <i class="fa fa-plus-circle fa-lg green" aria-hidden="true"></i>
          </a>
        </div>
      </div>

      <div class="calculator-item pt-1">
        <div class="pb-1">
          <h3>#{t(lang, "calculator", "portions_question") || "How many portions you want?"}</h3>
        </div>
        <input id="portion-slider" type="range"
               min="1" max="200" step="1" value="#{portion}" />
        <div class="calculator-control mt-1">
          <a href="#" id="decrease-servings">
            <i class="fa fa-minus-circle fa-lg yellow" aria-hidden="true"></i>
          </a>
          <input id="portion-input" type="number" step="any" class="calculator-input mr-1 ml-1" onchange="updatePortion(this.value)" />
          <span id="portion-label" class="mr-1">#{t(lang, "calculator", "portions_label") || "portions"}</span>
          <a href="#" id="increase-servings">
            <i class="fa fa-plus-circle fa-lg green" aria-hidden="true"></i>
          </a>
        </div>
      </div>
    </div>
  HTML
end

def html_dosage_widget_content(lang)
  <<~HTML
    <p class="mb-2 mt-2">
      <i class="fa fa-cookie fa-lg green icon-large" aria-hidden="true"></i>
      #{t(lang, "calculator", "full_recipe") || "Full recipe:"} <span class="badge badge-success badge-label badge-label-large" id="potency-result-total">0</span>
    </p>

    <p class="mb-2 mt-3">
      <i class="fa fa-cookie-bite fa-lg green icon-large" aria-hidden="true"></i>
      #{t(lang, "calculator", "per_portion") || "Per portion:"} <span class="badge badge-success badge-label" id="potency-result">0</span>
    </p>

    <p id="highness-level" class="mb-2 mt-3"></p>

    <h3 class="dosage-effects-title mt-4">
      <i class="far fa-laugh green mr-1" aria-hidden="true"></i> #{t(lang, "calculator", "positive_effects") || "Positive Effects"}
    </h3>
    <p class="spaced-content mt-1 pb-2" id="positive-effect-details"></p>

    <h3 class="dosage-effects-title mt-3">
      <i class="far fa-frown red mr-1" aria-hidden="true"></i> #{t(lang, "calculator", "negative_effects") || "Negative Effects"}
    </h3>
    <p class="spaced-content mt-1 pb-2" id="negative-effect-details"></p>

    <p class="sidenote mt-2">#{t(lang, "calculator", "side_note") || "You may or may not feel all the effects listed*"}</p>
  HTML
end

def i18n_script(lang)
  js_data = t(lang, "calculator_js")
  return "" unless js_data && lang != "en"
  "<script>window.I18N = #{JSON.generate(js_data)};</script>"
end

def wrap_page(lang:, page_path:, head_content:, body_content:, extra_scripts: "")
  html_lang = lang == "pt" ? "pt-BR" : lang
  prefix = lang_prefix(lang)
  search_redirect = "#{prefix}/"

  <<~HTML
    <!DOCTYPE html>
    <html lang="#{html_lang}">
    #{head_content}
      <body>
        #{html_navbar(lang, page_path)}
        <div class="container page-content">
          #{body_content}
        </div>
        #{html_footer(lang)}

        #{analytics_script}

        <!-- jQuery + Bootstrap 4 bundle -->
        <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
        <!-- Search redirect for non-homepage pages -->
        <script>
          (function(){
            var inp = document.getElementById('recipe-search');
            if (!inp || document.getElementById('pagination-controls')) return;
            inp.addEventListener('keydown', function(e){
              if (e.key === 'Enter') { e.preventDefault(); var q = inp.value.trim(); if (q) window.location.href = '#{search_redirect}?search=' + encodeURIComponent(q); }
            });
          })();
        </script>
        #{extra_scripts}
      </body>
    </html>
  HTML
end

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
  puts "  wrote: #{path.sub(ROOT_DIR + "/", "")}"
end

def output_path(lang, *parts)
  if lang == "en"
    File.join(ROOT_DIR, *parts)
  else
    File.join(ROOT_DIR, lang, *parts)
  end
end

# ─────────────────────────────────────────────
# Page Generators
# ─────────────────────────────────────────────

def build_homepage(lang)
  prefix = lang_prefix(lang)
  title       = t(lang, "homepage", "title") || "Edible Dosage Calculator | Cannabutter & Cannabis Recipes"
  description = t(lang, "homepage", "description") || "Find out how potent your edibles are! This edible dosage calculator helps you cook and dose cannabis edibles responsibly."
  canonical   = "#{SITE_URL}#{prefix}/"

  all_cards = RECIPES.map do |r|
    img_src = "#{IMAGE_BASE}/#{r["slug"]}.jpg"
    r_name = recipe_t(lang, r["slug"], "name") || r["name"]
    r_desc = recipe_t(lang, r["slug"], "description") || r["description"] || ""
    r_cat  = recipe_t(lang, r["slug"], "category_name") || r["category_name"]
    search_data = CGI.escapeHTML("#{r_name} #{r_cat} #{r_desc}".downcase)
    <<~HTML.strip
      <div class="col-12 col-sm-3 recipe-card-item" data-search="#{search_data}">
        <a href="#{prefix}/recipes/#{r["slug"]}/">
          <div class="card mb-2">
            <img src="#{img_src}" class="card-img-top" alt="#{CGI.escapeHTML(r_name)}" loading="lazy" />
            <div class="card-block">
              <p class="card-category">#{CGI.escapeHTML(r_cat)}</p>
              <p class="card-title">#{CGI.escapeHTML(r_name)}</p>
              <p class="card-text">#{CGI.escapeHTML(r_desc)}</p>
            </div>
          </div>
        </a>
      </div>
    HTML
  end.join("\n")

  hero_title = t(lang, "homepage", "hero_title") || "Cannabis Edibles Recipes"
  hero_sub = t(lang, "homepage", "hero_sub") || "Delicious recipes with a built-in dosage calculator so you always know what's in your food."
  popular = t(lang, "homepage", "popular_recipes") || "Popular recipes"
  no_results = t(lang, "homepage", "no_results") || "No recipes found. Try a different search."
  donate_title = t(lang, "homepage", "donate_cta_title") || "Enjoying the recipes?"
  donate_text = t(lang, "homepage", "donate_cta_text") || "This site is free and ad-light — help us keep it that way."
  donate_btn = t(lang, "homepage", "donate_cta_btn") || "Support us"

  body = <<~HTML
    <div class="homepage-hero mb-4">
      <div class="hero-text">
        <h1 class="hero-title">#{hero_title}</h1>
        <p class="hero-sub">#{hero_sub}</p>
      </div>
    </div>

    <div class="section-header mb-3">
      <i class="fa fa-fire-alt orange mr-2" aria-hidden="true"></i>
      <span>#{popular}</span>
    </div>

    <div class="row">
      #{all_cards}
    </div>

    <div class="donate-cta">
      <i class="fas fa-heart donate-cta-icon"></i>
      <div class="donate-cta-text">
        <strong>#{donate_title}</strong> #{donate_text}
      </div>
      <a href="#{prefix}/donate.html" class="donate-cta-btn">#{donate_btn}</a>
    </div>

    <div id="search-no-results">#{no_results}</div>
    <div id="pagination-controls" class="mt-3 mb-4"></div>
  HTML

  head = html_head(
    lang:        lang,
    title:       title,
    description: description,
    canonical:   canonical,
    page_path:   "/",
    og_image:    "#{SITE_URL}/images/pot-brownies.jpg"
  )

  page = wrap_page(
    lang:          lang,
    page_path:     "/",
    head_content:  head,
    body_content:  body,
    extra_scripts: '<script src="/js/homepage.js"></script>'
  )

  write_file(output_path(lang, "index.html"), page)
end

def build_recipe_page(recipe, lang)
  prefix      = lang_prefix(lang)
  slug        = recipe["slug"]
  name        = recipe_t(lang, slug, "name") || recipe["name"]
  quantity    = recipe["suggested_quantity"]  || 3.5
  portion     = recipe["suggested_portion"]   || 50
  potency     = 14
  description = recipe_t(lang, slug, "description") || recipe["description"] || ""
  category    = recipe_t(lang, slug, "category_name") || recipe["category_name"] || ""
  img_src     = "#{IMAGE_BASE}/#{slug}.jpg"
  page_path   = "/recipes/#{slug}/"
  canonical   = "#{SITE_URL}#{prefix}#{page_path}"
  og_image    = "#{SITE_URL}#{img_src}"

  title_suffix = t(lang, "recipe_page", "title_suffix") || "Cannabis Edibles Recipe | HowToEdibles"
  title       = "#{name} #{title_suffix}"
  title       = title[0, 60] + "…" if title.length > 62

  ingredients_html = recipe["ingredients"] || ""
  instructions_html = recipe["instructions"] || ""

  # ── Structured data ──────────────────────────────────────
  ingredients_list = extract_li_texts(ingredients_html)
  instructions_list = extract_li_texts(instructions_html)
  how_to_steps = instructions_list.map.with_index(1) do |text, i|
    { "@type" => "HowToStep", "position" => i, "text" => text }
  end

  recipe_schema = {
    "@context"         => "https://schema.org",
    "@type"            => "Recipe",
    "name"             => name,
    "description"      => description,
    "image"            => "#{SITE_URL}#{img_src}",
    "author"           => { "@type" => "Organization", "name" => "HowToEdibles", "url" => SITE_URL },
    "publisher"        => { "@type" => "Organization", "name" => "HowToEdibles", "url" => SITE_URL },
    "datePublished"    => "2024-01-01",
    "dateModified"     => Time.now.strftime("%Y-%m-%d"),
    "recipeCategory"   => category,
    "inLanguage"       => (lang == "pt" ? "pt-BR" : lang),
    "keywords"         => "cannabis #{name.downcase}, weed #{name.downcase}, infused #{name.downcase}, THC edible",
    "recipeYield"      => "#{portion.to_i} serving#{portion.to_i == 1 ? "" : "s"}",
    "recipeIngredient" => ingredients_list,
    "recipeInstructions" => how_to_steps,
    "url"              => canonical
  }
  recipe_schema.delete("recipeIngredient")  if ingredients_list.empty?
  recipe_schema.delete("recipeInstructions") if how_to_steps.empty?

  breadcrumb_schema = {
    "@context" => "https://schema.org",
    "@type"    => "BreadcrumbList",
    "itemListElement" => [
      { "@type" => "ListItem", "position" => 1, "name" => "Home",     "item" => "#{SITE_URL}#{prefix}/" },
      { "@type" => "ListItem", "position" => 2, "name" => category,   "item" => "#{SITE_URL}#{prefix}/" },
      { "@type" => "ListItem", "position" => 3, "name" => name }
    ]
  }

  schema_json = JSON.generate([recipe_schema, breadcrumb_schema])
  keywords    = "#{name}, #{category} cannabis recipe, how to make #{name.downcase}, cannabis #{name.downcase} recipe"

  video_html = ""
  if recipe["video"] && !recipe["video"].empty?
    video_html = <<~HTML
      <div class="video-container mt-4 mb-2">
        <iframe width="100%" height="300px" src="#{recipe["video"]}" frameborder="0" allowfullscreen></iframe>
      </div>
    HTML
  end

  desc_html = description.empty? ? "" : "<p class=\"recipe-page-description\">#{CGI.escapeHTML(description)}</p>"

  ingredients_label = t(lang, "recipe_page", "ingredients") || "Ingredients"
  directions_label = t(lang, "recipe_page", "directions") || "Directions"
  calc_label = t(lang, "calculator", "calculate_your_dose") || "Calculate Your Dose"
  check_label = t(lang, "calculator", "check_your_dose") || "Check Your Dose"

  recipe_col = <<~HTML
    #{html_leaderboard_ad}

    <div class="recipe-hero-img-wrap">
      <img src="#{img_src}" alt="#{CGI.escapeHTML(name)}" class="recipe-hero-img" />
    </div>

    <div class="recipe-header">
      <span class="recipe-category-badge">#{CGI.escapeHTML(category)}</span>
      <h1 class="recipe-page-title">#{CGI.escapeHTML(name)}</h1>
      #{desc_html}
    </div>

    <div class="recipe-section-card mb-4">
      <div class="recipe-section-header">
        <i class="fa fa-utensils" aria-hidden="true"></i>
        <span>#{ingredients_label}</span>
      </div>
      <div class="recipe-section-body">
        #{ingredients_html}
      </div>
    </div>

    <div class="recipe-section-card mb-4">
      <div class="recipe-section-header">
        <i class="fa fa-list-ol" aria-hidden="true"></i>
        <span>#{directions_label}</span>
      </div>
      <div class="recipe-section-body recipe-steps">
        #{instructions_html}
      </div>
    </div>

    #{video_html}
  HTML

  calculator_col = <<~HTML
    <div class="calculator-panel mb-3">
      <div class="calculator-panel-header">
        <i class="fa fa-calculator" aria-hidden="true"></i>
        <span>#{calc_label}</span>
      </div>
      <div class="calculator-panel-body">
        #{html_calculator_widget(lang, quantity: quantity, portion: portion, potency: potency)}
      </div>
    </div>

    <div class="dosage-panel">
      <div class="dosage-panel-header">
        <i class="fa fa-flask" aria-hidden="true"></i>
        <span>#{check_label}</span>
      </div>
      <div class="dosage-panel-body">
        #{html_dosage_widget_content(lang)}
      </div>
    </div>
  HTML

  body = <<~HTML
    <div class="row">
      <div class="col-md-7 order-1 order-md-1 recipe-left-col">
        #{recipe_col}
      </div>
      <div class="col-md-5 order-2 order-md-2 recipe-right-col">
        #{calculator_col}
      </div>
    </div>
  HTML

  default_desc = (t(lang, "recipe_page", "default_description_template") || "Learn how to make cannabis %{name} with our step-by-step recipe and built-in THC dosage calculator.").gsub("%{name}", name)

  recipe_defaults_script = <<~JS
    #{i18n_script(lang)}
    <script>
      window.RECIPE_DEFAULTS = { quantity: #{quantity}, portion: #{portion}, potency: #{potency} };
    </script>
    <script src="/js/calculator.js"></script>
  JS

  head = html_head(
    lang:        lang,
    title:       title,
    description: description.empty? ? default_desc : description,
    canonical:   canonical,
    page_path:   page_path,
    og_image:    og_image,
    og_type:     "article",
    schema_json: schema_json,
    keywords:    keywords
  )

  page = wrap_page(
    lang:          lang,
    page_path:     page_path,
    head_content:  head,
    body_content:  body,
    extra_scripts: recipe_defaults_script
  )

  write_file(output_path(lang, "recipes", slug, "index.html"), page)
end

def build_calculator_page(lang)
  prefix = lang_prefix(lang)
  title       = t(lang, "calculator", "page_title") || "Edible Dosage Calculator — Calculate THC mg Per Serving | HowToEdibles"
  description = t(lang, "calculator", "page_description") || "Free cannabis edible dosage calculator. Enter your weed amount, potency %, and number of servings to instantly find mg of THC per portion. Start low, go slow."
  page_path   = "/calculator.html"
  canonical   = "#{SITE_URL}#{prefix}#{page_path}"

  calc_label = t(lang, "calculator", "calculate_your_dose") || "Calculate Your Dose"
  check_label = t(lang, "calculator", "check_your_dose") || "Check Your Dose"

  # ── FAQ data ────────────────
  faqs = (1..6).map do |i|
    { q: t(lang, "faq", "q#{i}") || "", a: t(lang, "faq", "a#{i}") || "" }
  end.reject { |f| f[:q].empty? }

  # ── Schemas ─────────────────
  webapp_schema = {
    "@context"            => "https://schema.org",
    "@type"               => "WebApplication",
    "name"                => t(lang, "calculator", "calc_page_title") || "Cannabis Edible Dosage Calculator",
    "url"                 => canonical,
    "description"         => description,
    "applicationCategory" => "HealthApplication",
    "operatingSystem"     => "Any",
    "browserRequirements" => "Requires JavaScript",
    "inLanguage"          => (lang == "pt" ? "pt-BR" : lang),
    "offers"              => { "@type" => "Offer", "price" => "0", "priceCurrency" => "USD" },
    "creator"             => { "@type" => "Organization", "name" => "HowToEdibles", "url" => SITE_URL }
  }

  faq_schema = {
    "@context"   => "https://schema.org",
    "@type"      => "FAQPage",
    "mainEntity" => faqs.map do |f|
      {
        "@type"          => "Question",
        "name"           => f[:q],
        "acceptedAnswer" => { "@type" => "Answer", "text" => f[:a] }
      }
    end
  }

  schema_json = JSON.generate([webapp_schema, faq_schema])

  # ── Popular recipes ──────────
  featured_slugs = %w[cannabutter pot-brownies pot-cookies gummy-bears infused-coconut-oil infused-lemonade]
  featured = RECIPES.select { |r| featured_slugs.include?(r["slug"]) }
  recipe_links = featured.map do |r|
    r_name = recipe_t(lang, r["slug"], "name") || r["name"]
    "<a href=\"#{prefix}/recipes/#{r["slug"]}/\" class=\"calc-recipe-chip\">#{CGI.escapeHTML(r_name)}</a>"
  end.join("\n")

  # ── Dosage guide rows ───────
  dosage_rows = [
    [t(lang, "calculator", "dosage_microdose") || "Microdose",    "1–2.5 mg",   t(lang, "calculator", "dosage_microdose_desc") || "No or barely noticeable effect. Good for first-timers.", "table-success"],
    [t(lang, "calculator", "dosage_beginner") || "Beginner",     "2.5–5 mg",   t(lang, "calculator", "dosage_beginner_desc") || "Mild relaxation, light euphoria. Ideal starting dose.", "table-success"],
    [t(lang, "calculator", "dosage_casual") || "Casual",       "5–15 mg",    t(lang, "calculator", "dosage_casual_desc") || "Clear euphoria, altered perception. Common recreational dose.", ""],
    [t(lang, "calculator", "dosage_experienced") || "Experienced",  "15–30 mg",   t(lang, "calculator", "dosage_experienced_desc") || "Strong effects, may cause anxiety in low-tolerance users.", "table-warning"],
    [t(lang, "calculator", "dosage_high") || "High dose",    "30–50 mg",   t(lang, "calculator", "dosage_high_desc") || "Very intense. Recommended only for high-tolerance users.", "table-warning"],
    [t(lang, "calculator", "dosage_extreme") || "Extreme",      "50+ mg",     t(lang, "calculator", "dosage_extreme_desc") || "Overwhelming for most people. Medical patients only.", "table-danger"],
  ]

  dosage_table_rows = dosage_rows.map do |level, dose, effect, cls|
    "<tr class=\"#{cls}\"><td><strong>#{level}</strong></td><td>#{dose}</td><td>#{effect}</td></tr>"
  end.join("\n")

  # ── FAQ HTML ────────────────
  faq_items = faqs.map.with_index do |f, i|
    <<~HTML
      <div class="calc-faq-item">
        <button class="calc-faq-question" data-target="faq-#{i}" aria-expanded="false">
          #{CGI.escapeHTML(f[:q])}
          <i class="fa fa-chevron-down calc-faq-chevron" aria-hidden="true"></i>
        </button>
        <div class="calc-faq-answer" id="faq-#{i}">
          <p>#{CGI.escapeHTML(f[:a])}</p>
        </div>
      </div>
    HTML
  end.join("\n")

  faq_toggle_script = <<~JS
    <script>
      document.querySelectorAll('.calc-faq-question').forEach(function(btn) {
        btn.addEventListener('click', function() {
          var target = document.getElementById(this.dataset.target);
          var open = target.classList.toggle('open');
          this.setAttribute('aria-expanded', open);
          this.querySelector('.calc-faq-chevron').style.transform = open ? 'rotate(180deg)' : '';
        });
      });
    </script>
  JS

  # ── Right column content ────
  content_col = <<~HTML
    <article class="calc-info-col">
      <h1 class="calc-page-title">#{t(lang, "calculator", "calc_page_title") || "Cannabis Edible Dosage Calculator"}</h1>
      <p class="calc-page-intro">
        #{t(lang, "calculator", "calc_page_intro") || 'Use this free calculator to find out exactly how many <strong>milligrams of THC</strong> are in each portion of your cannabis edibles — before you cook. Enter your cannabis amount, strength, and number of servings. Instant, accurate results.'}
      </p>

      <h2 class="calc-section-title mt-4">#{t(lang, "calculator", "dosage_guide_title") || "THC Dosage Guide"}</h2>
      <p class="calc-section-sub">#{t(lang, "calculator", "dosage_guide_sub") || "How many mg is the right dose for you?"}</p>
      <div class="table-responsive mb-4">
        <table class="table table-sm calc-dosage-table">
          <thead>
            <tr><th>#{t(lang, "calculator", "dosage_level") || "Level"}</th><th>#{t(lang, "calculator", "dosage_per_serving") || "THC per serving"}</th><th>#{t(lang, "calculator", "dosage_effects") || "Expected effects"}</th></tr>
          </thead>
          <tbody>
            #{dosage_table_rows}
          </tbody>
        </table>
      </div>

      <h2 class="calc-section-title">#{t(lang, "calculator", "how_to_use_title") || "How to Use the Calculator"}</h2>
      <ol class="calc-steps-list">
        <li>#{t(lang, "calculator", "how_to_step_1") || 'Enter the <strong>grams of cannabis</strong> you plan to use.'}</li>
        <li>#{t(lang, "calculator", "how_to_step_2") || 'Set the <strong>THC percentage</strong> (check your dispensary label, or use the "Not sure?" guide).'}</li>
        <li>#{t(lang, "calculator", "how_to_step_3") || 'Enter the <strong>number of servings</strong> your recipe makes.'}</li>
        <li>#{t(lang, "calculator", "how_to_step_4") || 'The calculator instantly shows <strong>mg THC per serving</strong> and total potency.'}</li>
      </ol>
      <p class="mt-2"><a href="#{prefix}/how-a-cannabis-calculator-works.html">#{t(lang, "calculator", "how_math_works") || "How does the math work? →"}</a></p>

      <h2 class="calc-section-title mt-4">#{t(lang, "calculator", "try_recipe_title") || "Try It With a Recipe"}</h2>
      <p class="calc-section-sub">#{t(lang, "calculator", "try_recipe_sub") || "Open any recipe to pre-fill the calculator with suggested amounts:"}</p>
      <div class="calc-recipe-chips mb-4">
        #{recipe_links}
        <a href="#{prefix}/" class="calc-recipe-chip calc-recipe-chip--more">#{t(lang, "calculator", "all_recipes") || "All recipes →"}</a>
      </div>

      <h2 class="calc-section-title mt-4">#{t(lang, "calculator", "faq_title") || "Frequently Asked Questions"}</h2>
      <div class="calc-faq">
        #{faq_items}
      </div>

      <p class="sidenote mt-4">
        <i class="fa fa-shield-alt orange mr-1"></i>
        #{t(lang, "calculator", "safety_note") || "Always start low and go slow. Wait at least 2 hours before taking more. This calculator is for educational purposes only."}
      </p>
    </article>
  HTML

  body = <<~HTML
    #{html_leaderboard_ad}
    <div class="row mt-3">
      <div class="col-md-5">
        <div class="calculator-panel mb-3">
          <div class="calculator-panel-header">
            <i class="fa fa-calculator" aria-hidden="true"></i>
            <span>#{calc_label}</span>
          </div>
          <div class="calculator-panel-body">
            #{html_calculator_widget(lang, quantity: 3.5, portion: 50, potency: 14)}
          </div>
        </div>
        <div class="dosage-panel">
          <div class="dosage-panel-header">
            <i class="fa fa-flask" aria-hidden="true"></i>
            <span>#{check_label}</span>
          </div>
          <div class="dosage-panel-body">
            #{html_dosage_widget_content(lang)}
          </div>
        </div>
      </div>
      <div class="col-md-7 recipe-left-col">
        #{content_col}
      </div>
    </div>
  HTML

  recipe_defaults_script = <<~JS
    #{i18n_script(lang)}
    <script>
      window.RECIPE_DEFAULTS = { quantity: 3.5, portion: 50, potency: 14 };
    </script>
    <script src="/js/calculator.js"></script>
    #{faq_toggle_script}
  JS

  head = html_head(
    lang:        lang,
    title:       title,
    description: description,
    canonical:   canonical,
    page_path:   page_path,
    keywords:    "edible dosage calculator, THC mg calculator, cannabis edible potency, how to dose edibles, weed edible calculator, marijuana edibles calculator",
    schema_json: schema_json
  )

  page = wrap_page(
    lang:          lang,
    page_path:     page_path,
    head_content:  head,
    body_content:  body,
    extra_scripts: recipe_defaults_script
  )

  write_file(output_path(lang, "calculator.html"), page)
end

def build_404_page(lang)
  prefix = lang_prefix(lang)
  page_path = "/404.html"
  head = html_head(
    lang:        lang,
    title:       t(lang, "page_404", "title") || "Page Not Found | HowToEdibles",
    description: t(lang, "page_404", "description") || "Sorry, that page could not be found.",
    canonical:   "#{SITE_URL}#{prefix}#{page_path}",
    page_path:   page_path
  )

  body = <<~HTML
    <div class="text-center mt-5 mb-5">
      <h1>#{t(lang, "page_404", "heading") || "404"}</h1>
      <p class="spaced-subtitle">#{t(lang, "page_404", "message") || "Sorry, that page could not be found."}</p>
      <a href="#{prefix}/" class="btn btn-success">#{t(lang, "page_404", "go_home") || "Go to Home"}</a>
    </div>
  HTML

  page = wrap_page(lang: lang, page_path: page_path, head_content: head, body_content: body)
  write_file(output_path(lang, "404.html"), page)
end

def build_donate_page(lang)
  prefix = lang_prefix(lang)
  page_path = "/donate.html"
  head = html_head(
    lang:        lang,
    title:       t(lang, "donate", "title") || "Support HowToEdibles | Donate",
    description: t(lang, "donate", "description") || "Help us keep HowToEdibles free. If this site has been useful, consider making a small donation.",
    canonical:   "#{SITE_URL}#{prefix}#{page_path}",
    page_path:   page_path
  )

  body = <<~HTML
    <div class="donate-page">
      <div class="row justify-content-center">
        <div class="col-md-7 col-lg-6">

          <div class="donate-hero text-center">
            <div class="donate-icon">
              <i class="fas fa-heart"></i>
            </div>
            <h1 class="donate-title">#{t(lang, "donate", "heading") || "Support HowToEdibles"}</h1>
            <p class="donate-subtitle">#{t(lang, "donate", "subtitle") || "This website is free and always will be. If it has helped you, consider buying us a coffee."}</p>
          </div>

          <div class="donate-card">
            <p>#{t(lang, "donate", "paragraph_1") || "We put a lot of work into making cannabis edibles safe, fun and accessible. The dosage calculator, the recipes, the harm reduction guides — everything is free and ad-light."}</p>
            <p>#{t(lang, "donate", "paragraph_2") || "Running a website has costs. If you've found value here, even a small contribution helps us keep the lights on and add new content."}</p>

            <div class="text-center mt-4 mb-3">
              <a href="https://bit.ly/donateht" target="_blank" rel="noopener noreferrer" class="btn-donate">
                <i class="fas fa-heart mr-2"></i> #{t(lang, "donate", "donate_btn") || "Donate via PayPal"}
              </a>
            </div>

            <p class="donate-note">#{t(lang, "donate", "thank_you") || "Every contribution, big or small, is genuinely appreciated. Thank you for being part of this community."}</p>
          </div>

          <div class="donate-features">
            <div class="donate-feature">
              <i class="fas fa-calculator orange"></i>
              <span>#{t(lang, "donate", "feature_calculator") || "Free dosage calculator for everyone"}</span>
            </div>
            <div class="donate-feature">
              <i class="fas fa-book-open orange"></i>
              <span>#{t(lang, "donate", "feature_recipes") || "41+ tested cannabis recipes"}</span>
            </div>
            <div class="donate-feature">
              <i class="fas fa-shield-alt orange"></i>
              <span>#{t(lang, "donate", "feature_safety") || "Harm reduction guides & safety tips"}</span>
            </div>
          </div>

        </div>
      </div>
    </div>
  HTML

  page = wrap_page(lang: lang, page_path: page_path, head_content: head, body_content: body)
  write_file(output_path(lang, "donate.html"), page)
end

# ─────────────────────────────────────────────
# Sitemap Generator
# ─────────────────────────────────────────────

def build_sitemap
  today = Time.now.strftime("%Y-%m-%d")

  # Collect all page paths with their priorities
  pages = []
  pages << { path: "/", priority: "1.0", changefreq: "weekly" }
  pages << { path: "/calculator.html", priority: "0.9", changefreq: "monthly" }
  pages << { path: "/donate.html", priority: "0.3", changefreq: "yearly" }

  RECIPES.each do |r|
    priority = %w[cannabutter infused-coconut-oil infused-olive-oil pot-brownies pot-cookies].include?(r["slug"]) ? "0.9" : "0.8"
    pages << { path: "/recipes/#{r["slug"]}/", priority: priority, changefreq: "monthly" }
  end

  # Check for article HTML files in root
  Dir.glob(File.join(ROOT_DIR, "*.html")).each do |f|
    basename = File.basename(f)
    next if %w[index.html calculator.html donate.html 404.html articles.html].include?(basename)
    pages << { path: "/#{basename}", priority: "0.7", changefreq: "monthly" }
  end

  # articles.html
  if File.exist?(File.join(ROOT_DIR, "articles.html"))
    pages << { path: "/articles.html", priority: "0.8", changefreq: "weekly" }
  end

  xml = '<?xml version="1.0" encoding="UTF-8"?>' + "\n"
  xml += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">' + "\n"

  pages.each do |pg|
    LANGS.each do |lang|
      prefix = lang_prefix(lang)
      loc = "#{SITE_URL}#{prefix}#{pg[:path]}"

      xml += "  <url>\n"
      xml += "    <loc>#{loc}</loc>\n"
      xml += "    <lastmod>#{today}</lastmod>\n"
      xml += "    <changefreq>#{pg[:changefreq]}</changefreq>\n"
      xml += "    <priority>#{pg[:priority]}</priority>\n"

      # Add hreflang xhtml:link for all language versions
      LANGS.each do |l|
        l_prefix = lang_prefix(l)
        hreflang = l == "en" ? "en" : (l == "pt" ? "pt-BR" : l)
        xml += "    <xhtml:link rel=\"alternate\" hreflang=\"#{hreflang}\" href=\"#{SITE_URL}#{l_prefix}#{pg[:path]}\" />\n"
      end
      xml += "    <xhtml:link rel=\"alternate\" hreflang=\"x-default\" href=\"#{SITE_URL}#{pg[:path]}\" />\n"

      xml += "  </url>\n"
    end
  end

  xml += "</urlset>\n"

  write_file(File.join(ROOT_DIR, "sitemap.xml"), xml)
end

# ─────────────────────────────────────────────
# Main Build
# ─────────────────────────────────────────────

LANGS.each do |lang|
  puts "\n=== Building #{lang.upcase} ==="

  puts "  --- Homepage ---"
  build_homepage(lang)

  puts "  --- Recipe pages ---"
  RECIPES.each { |r| build_recipe_page(r, lang) }

  puts "  --- Calculator page ---"
  build_calculator_page(lang)

  puts "  --- 404 page ---"
  build_404_page(lang)

  puts "  --- Donation page ---"
  build_donate_page(lang)
end

puts "\n=== Building sitemap ==="
build_sitemap

puts "\nDone! #{RECIPES.count} recipe pages × #{LANGS.count} languages = #{RECIPES.count * LANGS.count} pages generated."
