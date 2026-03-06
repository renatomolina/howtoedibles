#!/usr/bin/env ruby
# scripts/build_site.rb
# i18n build script — generates /pt/, /es/, /de/ pages from English originals.
# NEVER overwrites English root files — those are hand-maintained.
#
# Run: ruby scripts/build_site.rb

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

LANGS = %w[pt es de]  # non-English only — English is hand-maintained
ALL_LANGS = %w[en pt es de]  # for hreflang tags

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

puts "Building site from #{RECIPES.count} recipes across #{CATEGORIES.count} categories in #{LANGS.count} languages (pt, es, de)..."
puts "English files are NOT touched — they are hand-maintained."

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
  html_str.scan(/<li[^>]*>(.*?)<\/li>/m).map { |m| m[0].gsub(/<[^>]+>/, "").strip }
end

def lang_html(lang)
  case lang
  when "pt" then "pt-BR"
  else lang
  end
end

# ─────────────────────────────────────────────
# Output Helpers
# ─────────────────────────────────────────────

def output_path(lang, *segments)
  File.join(ROOT_DIR, lang, *segments)
end

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

# ─────────────────────────────────────────────
# hreflang tags for all pages
# ─────────────────────────────────────────────

def hreflang_tags(page_path)
  # page_path is the language-neutral path like "" (homepage), "calculator.html", "recipes/cannabutter/"
  # Strip any leading lang prefix if accidentally included
  page_path = page_path.sub(%r{^(pt|es|de)/}, "")
  tags = []
  ALL_LANGS.each do |l|
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

def build_head(lang, title:, description:, canonical:, keywords: nil, structured_data: nil, extra_head: "")
  html_lang = lang_html(lang)
  prefix = lang_prefix(lang)
  # Extract language-neutral page path for hreflang
  page_path = canonical.sub("https://www.howtoedibles.com", "").sub(/^\//, "")
  page_path = page_path.sub(%r{^(pt|es|de)/}, "")

  kw = keywords || "edible dosage calculator, cannabis edibles, how much weed for edibles, THC calculator, edible potency, marijuana edibles, cannabis dosage, weed edibles"

  sd_block = if structured_data && !structured_data.empty?
    "\n  <!-- Structured Data -->\n  <script type=\"application/ld+json\">\n#{structured_data}\n</script>"
  else
    "\n  <!-- Structured Data -->\n  "
  end

  <<~HTML
    <!DOCTYPE html>
    <html lang="#{html_lang}">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
      <title>#{h(title)}</title>
      <meta name="description" content="#{h(description)}" />
      <link rel="canonical" href="#{canonical}" />
      <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />

      <!-- Open Graph -->
      <meta property="og:type" content="website" />
      <meta property="og:site_name" content="HowToEdibles" />
      <meta property="og:title" content="#{h(title)}" />
      <meta property="og:description" content="#{h(description)}" />
      <meta property="og:image" content="https://www.howtoedibles.com/images/pot-brownies.jpg" />
      <meta property="og:url" content="#{canonical}" />

      <!-- Twitter -->
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content="#{h(title)}" />
      <meta name="twitter:description" content="#{h(description)}" />
      <meta name="twitter:image" content="https://www.howtoedibles.com/images/pot-brownies.jpg" />

      <meta name="keywords" content="#{h(kw)}" />
      <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />

      <!-- hreflang -->
      #{hreflang_tags(page_path)}
    #{sd_block}

      <!-- Bootstrap 4 -->
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" crossorigin="anonymous" />
      <!-- Font Awesome -->
      <link rel="preload" as="style" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" onload="this.rel='stylesheet'" />
      <noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" /></noscript>
      <!-- Site CSS -->
      <link rel="stylesheet" href="/css/styles.css" />
      <script>try{if(localStorage.getItem("theme")==="dark")document.documentElement.setAttribute("data-theme","dark")}catch(e){}</script>

      <script>
      function downloadJSAtOnload() {
        var el = document.createElement("script");
        el.src = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6354522716906819";
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

  category_order = %w[Desserts Drinks Snacks Essentials Lunch Keto Vegan Mocktails International]

  dropdowns = category_order.map do |cat_name|
    cat = cats_by_name[cat_name]
    next unless cat
    cat_recipes = RECIPES.select { |r| r["category_id"] == cat["id"] }
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
    #{dropdowns}      </ul>
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
  # Simple language links in the footer for now — clean and SEO-friendly
  ""
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
              <li><a href="/articles.html">#{h(articles_label)}</a></li>
              <li><a href="/how-a-cannabis-calculator-works.html">#{h(how_calc)}</a></li>
              <li><a href="/how-to-prevent-a-bad-trip.html">#{h(prevent_trip)}</a></li>
              <li><a href="https://bit.ly/helpimhavingabadtrip" target="_blank" rel="noopener noreferrer">#{h(bad_trip_chat)}</a></li>
              <li><a href="#{prefix}/donate.html">#{h(support_us)}</a></li>
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
    <script async src="https://www.googletagmanager.com/gtag/js?id=UA-90858722-1"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'UA-90858722-1');
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

def build_i18n_script(lang)
  js_i18n = t(lang, "calculator_js")
  return "" unless js_i18n.is_a?(Hash)
  "<script>window.I18N = #{JSON.generate(js_i18n)};</script>\n"
end

# ─────────────────────────────────────────────
# Ad blocks
# ─────────────────────────────────────────────

LEADERBOARD_AD = <<~HTML
  <div class="row d-none d-md-block text-center">
    <!-- Leaderboard -->
    <ins class="adsbygoogle"
         style="display:inline-block;width:750px;height:90px"
         data-ad-client="ca-pub-6354522716906819"
         data-ad-slot="4353785890"></ins>
    <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
  </div>
HTML

MOBILE_AD = <<~HTML
  <div class="mt-2 mb-3 d-sm-none">
    <!-- Medium Rectangle -->
    <ins class="adsbygoogle"
         style="display:block"
         data-ad-client="ca-pub-6354522716906819"
         data-ad-slot="5475295879"
         data-ad-format="auto"></ins>
    <script>(adsbygoogle = window.adsbygoogle || []).push({});</script>
  </div>
HTML

# ─────────────────────────────────────────────
# Calculator widget (shared between homepage calculator page and recipe pages)
# ─────────────────────────────────────────────

def build_calculator_widget(lang, defaults: { quantity: 3.5, potency: 14, portion: 50 })
  prefix = lang_prefix(lang)
  weed_q = t(lang, "calculator", "weed_quantity")
  weed_s = t(lang, "calculator", "weed_strength")
  avg_tip = t(lang, "calculator", "average_tip")
  not_sure = t(lang, "calculator", "not_sure")
  portions_q = t(lang, "calculator", "portions_question")
  portions_l = t(lang, "calculator", "portions_label")
  potency_title = t(lang, "calculator", "potency_modal_title")
  potency_low = t(lang, "calculator", "potency_low")
  potency_med = t(lang, "calculator", "potency_medium")
  potency_high = t(lang, "calculator", "potency_high")
  potency_conc = t(lang, "calculator", "potency_concentrates")
  modal_close = t(lang, "calculator", "modal_close")

  qty_val = defaults[:quantity]
  str_val = defaults[:potency]
  por_val = defaults[:portion]

  <<~HTML
    <div id="calculator-widget">
      <div class="calculator-item pt-1">
        <div class="pb-1">
          <h3>#{h(weed_q)}</h3>
        </div>
        <input id="grams-slider" type="range"
               min="0.01" max="28" step="0.1" value="#{qty_val}" />
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
        <h3>#{h(weed_s)}</h3>
        <div class="average-tip mb-2">
          <span class="bottomtip">#{h(avg_tip)}</span>
          <a class="potency-help-btn ml-2" data-toggle="modal" href="#" data-target="#myModal">
            <i class="fa fa-circle-question fa-xs" aria-hidden="true"></i> #{h(not_sure)}
          </a>
        </div>
        <input id="strength-slider" type="range"
               min="1" max="99" step="1" value="#{str_val}" />

        <!-- Potency reference modal -->
        <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
          <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content potency-modal-content">
              <div class="modal-header potency-modal-header">
                <h5 class="modal-title" id="myModalLabel">
                  <i class="fa fa-leaf mr-2" aria-hidden="true"></i>Potency Guide
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body p-0">
                <div class="potency-rows">
                  <div class="potency-row potency-row--low">
                    <div class="potency-row-label">#{h(potency_low)}</div>
                    <div class="potency-row-range">5% &ndash; 10%</div>
                  </div>
                  <div class="potency-row potency-row--medium">
                    <div class="potency-row-label">#{h(potency_med)}</div>
                    <div class="potency-row-range">10% &ndash; 15%</div>
                  </div>
                  <div class="potency-row potency-row--high">
                    <div class="potency-row-label">#{h(potency_high)}</div>
                    <div class="potency-row-range">15% &ndash; 40%</div>
                  </div>
                  <div class="potency-row potency-row--conc">
                    <div class="potency-row-label">#{h(potency_conc)}</div>
                    <div class="potency-row-range">35% &ndash; 95%</div>
                  </div>
                </div>
                <p class="potency-avg-note">Street weed averages ~14% THC</p>
              </div>
              <div class="modal-footer potency-modal-footer">
                <button type="button" class="btn btn-potency-close" data-dismiss="modal">#{h(modal_close)}</button>
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
          <h3>#{h(portions_q)}</h3>
        </div>
        <input id="portion-slider" type="range"
               min="1" max="200" step="1" value="#{por_val}" />
        <div class="calculator-control mt-1">
          <a href="#" id="decrease-servings">
            <i class="fa fa-minus-circle fa-lg yellow" aria-hidden="true"></i>
          </a>
          <input id="portion-input" type="number" step="any" class="calculator-input mr-1 ml-1" onchange="updatePortion(this.value)" />
          <span id="portion-label" class="mr-1">#{h(portions_l)}</span>
          <a href="#" id="increase-servings">
            <i class="fa fa-plus-circle fa-lg green" aria-hidden="true"></i>
          </a>
        </div>
      </div>
    </div>
  HTML
end

def build_dosage_panel(lang, style: :recipe)
  full_recipe = t(lang, "calculator", "full_recipe")
  per_portion = t(lang, "calculator", "per_portion")
  pos_effects = t(lang, "calculator", "positive_effects")
  neg_effects = t(lang, "calculator", "negative_effects")
  side_note = "Effects vary by person, tolerance, and method of consumption."

  if style == :calculator
    <<~HTML
      <div class="dosage-panel">
        <div class="dosage-panel-header">
          <i class="fa fa-flask" aria-hidden="true"></i>
          <span>#{h(t(lang, "calculator", "check_your_dose"))}</span>
        </div>
        <div class="dosage-panel-body">
          <p class="mb-2 mt-2">
        <i class="fa fa-cookie fa-lg green icon-large" aria-hidden="true"></i>
        #{h(full_recipe)} <span class="badge badge-success badge-label badge-label-large" id="potency-result-total">0</span>
      </p>

      <p class="mb-2 mt-3">
        <i class="fa fa-cookie-bite fa-lg green icon-large" aria-hidden="true"></i>
        #{h(per_portion)} <span class="badge badge-success badge-label" id="potency-result">0</span>
      </p>

      <p id="highness-level" class="mb-2 mt-3"></p>

      <h3 class="dosage-effects-title mt-4">
        <i class="far fa-laugh green mr-1" aria-hidden="true"></i> #{h(pos_effects)}
      </h3>
      <p class="spaced-content mt-1 pb-2" id="positive-effect-details"></p>

      <h3 class="dosage-effects-title mt-3">
        <i class="far fa-frown red mr-1" aria-hidden="true"></i> #{h(neg_effects)}
      </h3>
      <p class="spaced-content mt-1 pb-2" id="negative-effect-details"></p>

      <p class="sidenote">#{h(side_note)}</p>

        </div>
      </div>
    HTML
  else
    <<~HTML
      <div class="dosage-panel">
        <div class="dosage-panel-header">
          <i class="fa fa-leaf" aria-hidden="true"></i>
          <span>Your Dose</span>
        </div>
        <div class="dosage-panel-body">
          <div class="dose-cards">
            <div class="dose-card">
              <i class="fa fa-cookie" aria-hidden="true"></i>
              <div class="dose-card-value" id="potency-result-total">&mdash;</div>
              <div class="dose-card-label">#{h(full_recipe).sub(/:$/, "")}</div>
            </div>
            <div class="dose-card dose-card--highlight">
              <i class="fa fa-cookie-bite" aria-hidden="true"></i>
              <div class="dose-card-value" id="potency-result">&mdash;</div>
              <div class="dose-card-label">#{h(per_portion).sub(/:$/, "")}</div>
            </div>
          </div>
          <p id="highness-level" class="mb-3"></p>

      <h3 class="dosage-effects-title mt-3">
        <i class="far fa-laugh green mr-1" aria-hidden="true"></i> #{h(pos_effects)}
      </h3>
      <p class="spaced-content mt-1 pb-2" id="positive-effect-details"></p>

      <h3 class="dosage-effects-title mt-3">
        <i class="far fa-frown red mr-1" aria-hidden="true"></i> #{h(neg_effects)}
      </h3>
      <p class="spaced-content mt-1 pb-2" id="negative-effect-details"></p>

      <p class="sidenote">#{h(side_note)}</p>

        </div>
      </div>
    HTML
  end
end


# ═════════════════════════════════════════════
# PAGE BUILDERS
# ═════════════════════════════════════════════

# ─────────────────────────────────────────────
# Homepage
# ─────────────────────────────────────────────

def build_homepage(lang)
  prefix = lang_prefix(lang)
  title = t(lang, "homepage", "title")
  description = t(lang, "homepage", "description")
  hero_title = t(lang, "homepage", "hero_title")
  hero_sub = t(lang, "homepage", "hero_sub")
  popular = t(lang, "homepage", "popular_recipes")
  no_results = t(lang, "homepage", "no_results")
  donate_title = t(lang, "homepage", "donate_cta_title")
  donate_text = t(lang, "homepage", "donate_cta_text")
  donate_btn = t(lang, "homepage", "donate_cta_btn")

  canonical = "https://www.howtoedibles.com#{prefix}/"

  # Recipe cards
  cards = RECIPES.map do |r|
    name = recipe_t(lang, r["slug"], "name") || r["name"]
    desc = recipe_t(lang, r["slug"], "description") || r["description"]
    cat = recipe_t(lang, r["slug"], "category_name") || r["category_name"]
    search_data = "#{name} #{cat} #{desc}".downcase

    <<~CARD
      <div class="col-12 col-sm-3 recipe-card-item" data-search="#{h(search_data)}">
        <a href="#{prefix}/recipes/#{r["slug"]}/">
          <div class="card mb-2">
            <img src="#{IMAGE_BASE}/#{r["slug"]}.jpg" class="card-img-top" alt="#{h(name)}" loading="lazy" />
            <div class="card-block">
              <p class="card-category">#{h(cat)}</p>
              <p class="card-title">#{h(name)}</p>
              <p class="card-text">#{h(desc)}</p>
            </div>
          </div>
        </a>
      </div>
    CARD
  end.join("")

  structured = JSON.generate({
    "@context" => "https://schema.org",
    "@type" => "WebSite",
    "name" => "HowToEdibles",
    "url" => canonical,
    "description" => description
  })

  page = build_head(lang, title: title, description: description, canonical: canonical, structured_data: structured)
  page << build_navbar(lang)
  page << <<~HTML
        <div class="container page-content">
    #{LEADERBOARD_AD}

    <div class="homepage-hero">
      <h1 class="homepage-h1">#{hero_title}</h1>
      <p class="homepage-intro">#{hero_sub}</p>
      <div class="hero-stats">
        <span class="hero-stat"><i class="fa fa-book-open"></i> 420+ recipes</span>
        <span class="hero-stat"><i class="fa fa-calculator"></i> Free calculator</span>
        <span class="hero-stat"><i class="fa fa-shield-halved"></i> Dose responsibly</span>
      </div>
    </div>

    <div class="section-header mb-3">
      <i class="fa fa-fire-alt orange mr-2" aria-hidden="true"></i>
      <span>#{h(popular)}</span>
    </div>

    <div class="row">
    #{cards}
    </div>

    <div class="donate-cta">
      <i class="fas fa-heart donate-cta-icon"></i>
      <div class="donate-cta-text">
        <strong>#{h(donate_title)}</strong> #{h(donate_text)}
      </div>
      <a href="#{prefix}/donate.html" class="donate-cta-btn">#{h(donate_btn)}</a>
    </div>

    <div id="search-no-results">#{h(no_results)}</div>
    <div id="pagination-controls" class="mt-3 mb-4"></div>

        </div>
  HTML
  page << build_footer(lang)
  page << build_scripts(lang, extra_scripts: "<script src=\"/js/homepage.js\"></script>\n")

  write_file(output_path(lang, "index.html"), page)
end

# ─────────────────────────────────────────────
# Calculator page
# ─────────────────────────────────────────────

def build_calculator_page(lang)
  prefix = lang_prefix(lang)
  title = t(lang, "calculator", "page_title")
  description = t(lang, "calculator", "page_description")
  canonical = "https://www.howtoedibles.com#{prefix}/calculator.html"

  calc_title_label = t(lang, "calculator", "calculate_your_dose")
  calc_page_title = t(lang, "calculator", "calc_page_title")
  calc_page_intro = t(lang, "calculator", "calc_page_intro")
  dosage_guide = t(lang, "calculator", "dosage_guide_title")
  dosage_guide_sub = t(lang, "calculator", "dosage_guide_sub")
  how_to_use = t(lang, "calculator", "how_to_use_title")
  try_recipe = t(lang, "calculator", "try_recipe_title")
  try_recipe_sub = t(lang, "calculator", "try_recipe_sub")
  all_recipes_label = t(lang, "calculator", "all_recipes")
  faq_title = t(lang, "calculator", "faq_title")
  safety = t(lang, "calculator", "safety_note")
  how_math = t(lang, "calculator", "how_math_works")

  # Dosage table
  levels = [
    ["table-success", t(lang, "calculator", "dosage_microdose"), "1&ndash;2.5 mg", t(lang, "calculator", "dosage_microdose_desc")],
    ["table-success", t(lang, "calculator", "dosage_beginner"), "2.5&ndash;5 mg", t(lang, "calculator", "dosage_beginner_desc")],
    ["", t(lang, "calculator", "dosage_casual"), "5&ndash;15 mg", t(lang, "calculator", "dosage_casual_desc")],
    ["table-warning", t(lang, "calculator", "dosage_experienced"), "15&ndash;30 mg", t(lang, "calculator", "dosage_experienced_desc")],
    ["table-warning", t(lang, "calculator", "dosage_high"), "30&ndash;50 mg", t(lang, "calculator", "dosage_high_desc")],
    ["table-danger", t(lang, "calculator", "dosage_extreme"), "50+ mg", t(lang, "calculator", "dosage_extreme_desc")],
  ]

  table_rows = levels.map do |cls, name, range, desc|
    %(<tr class="#{cls}"><td><strong>#{h(name)}</strong></td><td>#{range}</td><td>#{h(desc)}</td></tr>)
  end.join("\n")

  # How to use steps
  steps = (1..4).map { |i| "<li>#{t(lang, "calculator", "how_to_step_#{i}")}</li>" }.join("\n    ")

  # Recipe chips
  chip_recipes = %w[cannabutter infused-coconut-oil infused-lemonade gummy-bears pot-cookies pot-brownies]
  chips = chip_recipes.map do |slug|
    r = RECIPES.find { |rx| rx["slug"] == slug }
    next unless r
    name = recipe_t(lang, slug, "name") || r["name"]
    %(<a href="#{prefix}/recipes/#{slug}/" class="calc-recipe-chip">#{h(name)}</a>)
  end.compact.join("\n")

  # FAQ
  faq_items = (1..6).map do |i|
    q = t(lang, "faq", "q#{i}")
    a = t(lang, "faq", "a#{i}")
    <<~FAQ
      <div class="calc-faq-item">
        <button class="calc-faq-question" data-target="faq-#{i - 1}" aria-expanded="false">
          #{h(q)}
          <i class="fa fa-chevron-down calc-faq-chevron" aria-hidden="true"></i>
        </button>
        <div class="calc-faq-answer" id="faq-#{i - 1}">
          <p>#{h(a)}</p>
        </div>
      </div>
    FAQ
  end.join("")

  # Structured data (FAQ + WebApp)
  faq_sd = (1..6).map do |i|
    { "@type" => "Question", "name" => t(lang, "faq", "q#{i}"), "acceptedAnswer" => { "@type" => "Answer", "text" => t(lang, "faq", "a#{i}") } }
  end

  structured = JSON.generate([
    { "@context" => "https://schema.org", "@type" => "WebApplication", "name" => calc_page_title, "url" => canonical, "description" => description, "applicationCategory" => "HealthApplication", "operatingSystem" => "Any" },
    { "@context" => "https://schema.org", "@type" => "FAQPage", "mainEntity" => faq_sd }
  ])

  i18n_script = build_i18n_script(lang)

  page = build_head(lang, title: title, description: description, canonical: canonical, structured_data: structured)
  page << build_navbar(lang)
  page << <<~HTML
        <div class="container page-content">
    #{LEADERBOARD_AD}

    <div class="row mt-3">
      <div class="col-md-5">
        <div class="calculator-panel mb-3">
          <div class="calculator-panel-header">
            <i class="fa fa-calculator" aria-hidden="true"></i>
            <span>#{h(calc_title_label)}</span>
          </div>
          <div class="calculator-panel-body">
    #{build_calculator_widget(lang)}
          </div>
        </div>
    #{MOBILE_AD}
    #{build_dosage_panel(lang, style: :calculator)}
      </div>
      <div class="col-md-7 recipe-left-col">
        <article class="calc-info-col">
      <h1 class="calc-page-title">#{h(calc_page_title)}</h1>
      <p class="calc-page-meta"><time datetime="2026-03-04">Updated March 2026</time></p>
      <p class="calc-page-intro">#{calc_page_intro}</p>

      <h2 class="calc-section-title mt-4">#{h(dosage_guide)}</h2>
      <p class="calc-section-sub">#{h(dosage_guide_sub)}</p>
      <div class="table-responsive mb-4">
        <table class="table table-sm calc-dosage-table">
          <thead>
            <tr><th>#{t(lang, "calculator", "dosage_level")}</th><th>#{t(lang, "calculator", "dosage_per_serving")}</th><th>#{t(lang, "calculator", "dosage_effects")}</th></tr>
          </thead>
          <tbody>
    #{table_rows}
          </tbody>
        </table>
      </div>

      <h2 class="calc-section-title">#{h(how_to_use)}</h2>
      <ol class="calc-steps-list">
        #{steps}
      </ol>
      <p class="mt-2"><a href="/how-a-cannabis-calculator-works.html">#{how_math}</a></p>

      <h2 class="calc-section-title mt-4">#{h(try_recipe)}</h2>
      <p class="calc-section-sub">#{h(try_recipe_sub)}</p>
      <div class="calc-recipe-chips mb-4">
    #{chips}
        <a href="#{prefix}/" class="calc-recipe-chip calc-recipe-chip--more">#{all_recipes_label}</a>
      </div>

      <h2 class="calc-section-title mt-4">#{h(faq_title)}</h2>
      <div class="calc-faq">
    #{faq_items}
      </div>

      <p class="sidenote mt-4">
        <i class="fa fa-shield-alt orange mr-1"></i>
        #{h(safety)}
      </p>
    </article>
      </div>
    </div>

        </div>
  HTML
  page << build_footer(lang)

  extra = <<~JS
    #{i18n_script}<script>
      window.RECIPE_DEFAULTS = { quantity: 3.5, portion: 50, potency: 14 };
    </script>
    <script src="/js/calculator.js"></script>
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

  page << build_scripts(lang, extra_scripts: extra)
  write_file(output_path(lang, "calculator.html"), page)
end

# ─────────────────────────────────────────────
# Recipe pages
# ─────────────────────────────────────────────

def build_recipe_page(recipe, lang)
  prefix = lang_prefix(lang)
  slug = recipe["slug"]
  name = recipe_t(lang, slug, "name") || recipe["name"]
  desc = recipe_t(lang, slug, "description") || recipe["description"]
  cat = recipe_t(lang, slug, "category_name") || recipe["category_name"]

  title_suffix = t(lang, "recipe_page", "title_suffix")
  title = "#{name} #{title_suffix}"
  canonical = "https://www.howtoedibles.com#{prefix}/recipes/#{slug}/"
  ingredients_label = t(lang, "recipe_page", "ingredients")
  directions_label = t(lang, "recipe_page", "directions")

  # Recipe defaults
  qty = recipe["quantity"] || 3.5
  por = recipe["portion"] || 12
  pot = recipe["potency"] || 14

  # Ingredients & Directions are pre-rendered HTML strings from recipes.json
  ingredients_html = recipe["ingredients"] || ""
  steps_html = recipe["instructions"] || ""

  # Structured data
  structured = JSON.generate([
    {
      "@context" => "https://schema.org", "@type" => "Recipe",
      "name" => name, "description" => desc,
      "image" => "https://www.howtoedibles.com#{IMAGE_BASE}/#{slug}.jpg",
      "author" => { "@type" => "Organization", "name" => "HowToEdibles", "url" => "https://www.howtoedibles.com" },
      "publisher" => { "@type" => "Organization", "name" => "HowToEdibles", "url" => "https://www.howtoedibles.com" },
      "datePublished" => "2024-01-01", "dateModified" => "2026-03-04",
      "recipeCategory" => cat,
      "recipeYield" => "#{por} servings",
      "recipeIngredient" => extract_list_items(recipe["ingredients"]),
      "recipeInstructions" => extract_list_items(recipe["instructions"]).each_with_index.map { |s, i| { "@type" => "HowToStep", "position" => i + 1, "text" => s } },
      "url" => canonical
    },
    {
      "@context" => "https://schema.org", "@type" => "BreadcrumbList",
      "itemListElement" => [
        { "@type" => "ListItem", "position" => 1, "name" => "Home", "item" => "https://www.howtoedibles.com#{prefix}/" },
        { "@type" => "ListItem", "position" => 2, "name" => cat, "item" => "https://www.howtoedibles.com#{prefix}/" },
        { "@type" => "ListItem", "position" => 3, "name" => name }
      ]
    }
  ])

  og_image = "https://www.howtoedibles.com#{IMAGE_BASE}/#{slug}.jpg"

  i18n_script = build_i18n_script(lang)

  page = build_head(lang, title: title, description: desc, canonical: canonical,
                    keywords: "#{name}, #{cat} cannabis recipe, how to make #{name.downcase}, cannabis #{name.downcase} recipe",
                    structured_data: structured,
                    extra_head: "")
  # Override OG image for recipe
  page.gsub!(%r{<meta property="og:image" content="[^"]*" />}, %(<meta property="og:image" content="#{og_image}" />))
  page.gsub!(%r{<meta name="twitter:image" content="[^"]*" />}, %(<meta name="twitter:image" content="#{og_image}" />))
  page.gsub!(%r{<meta property="og:type" content="website" />}, %(<meta property="og:type" content="article" />))

  page << build_navbar(lang)
  page << <<~HTML
        <div class="container page-content">
          <div class="row">
      <div class="col-md-7 order-1 order-md-1 recipe-left-col">
    #{LEADERBOARD_AD}

    <div class="recipe-hero-img-wrap">
      <img src="#{IMAGE_BASE}/#{slug}.jpg" alt="#{h(name)}" class="recipe-hero-img" />
    </div>

    <div class="recipe-header">
      <span class="recipe-category-badge">#{h(cat)}</span>
      <h1 class="recipe-page-title">#{h(name)}</h1>
      <p class="recipe-page-description">#{h(desc)}</p>
    </div>

    <div class="recipe-section-card mb-4">
      <div class="recipe-section-header">
        <i class="fa fa-utensils" aria-hidden="true"></i>
        <span>#{h(ingredients_label)}</span>
      </div>
      <div class="recipe-section-body">
        #{ingredients_html}
      </div>
    </div>

    <div class="recipe-section-card mb-4">
      <div class="recipe-section-header">
        <i class="fa fa-list-ol" aria-hidden="true"></i>
        <span>#{h(directions_label)}</span>
      </div>
      <div class="recipe-section-body recipe-steps">
        #{steps_html}
      </div>
    </div>

      </div>
      <div class="col-md-5 order-2 order-md-2 recipe-right-col">
        <div class="calculator-panel mb-3">
      <div class="calculator-panel-header">
        <i class="fa fa-calculator" aria-hidden="true"></i>
        <span>#{h(t(lang, "calculator", "calculate_your_dose"))}</span>
      </div>
      <div class="calculator-panel-body">
    #{build_calculator_widget(lang, defaults: { quantity: qty, potency: pot, portion: por })}
      </div>
    </div>

    #{build_dosage_panel(lang, style: :recipe)}

      </div>
    </div>

        </div>
  HTML
  page << build_footer(lang)

  extra = <<~JS
    #{i18n_script}<script>
      window.RECIPE_DEFAULTS = { quantity: #{qty}, portion: #{por.is_a?(Float) ? por : "#{por}.0"}, potency: #{pot} };
    </script>
    <script src="/js/calculator.js"></script>
  JS

  page << build_scripts(lang, extra_scripts: extra)
  write_file(output_path(lang, "recipes", slug, "index.html"), page)
end

# ─────────────────────────────────────────────
# Donate page
# ─────────────────────────────────────────────

def build_donate_page(lang)
  prefix = lang_prefix(lang)
  title = t(lang, "donate", "title")
  description = t(lang, "donate", "description")
  canonical = "https://www.howtoedibles.com#{prefix}/donate.html"

  heading = t(lang, "donate", "heading")
  subtitle = t(lang, "donate", "subtitle")
  p1 = t(lang, "donate", "paragraph_1")
  p2 = t(lang, "donate", "paragraph_2")
  btn = t(lang, "donate", "donate_btn")
  thanks = t(lang, "donate", "thank_you")
  f_calc = t(lang, "donate", "feature_calculator")
  f_recipes = t(lang, "donate", "feature_recipes")
  f_safety = t(lang, "donate", "feature_safety")

  page = build_head(lang, title: title, description: description, canonical: canonical)
  page << build_navbar(lang)
  page << <<~HTML
        <div class="container page-content">
          <div class="donate-page">
      <div class="row justify-content-center">
        <div class="col-md-7 col-lg-6">

          <div class="donate-hero text-center">
            <div class="donate-icon">
              <i class="fas fa-heart"></i>
            </div>
            <h1 class="donate-title">#{h(heading)}</h1>
            <p class="donate-subtitle">#{h(subtitle)}</p>
          </div>

          <div class="donate-card">
            <p>#{h(p1)}</p>
            <p>#{h(p2)}</p>

            <div class="text-center mt-4 mb-3">
              <a href="https://bit.ly/donateht" target="_blank" rel="noopener noreferrer" class="btn-donate">
                <i class="fas fa-heart mr-2"></i> #{h(btn)}
              </a>
            </div>

            <p class="donate-note">#{h(thanks)}</p>
          </div>

          <div class="donate-features">
            <div class="donate-feature">
              <i class="fas fa-calculator orange"></i>
              <span>#{h(f_calc)}</span>
            </div>
            <div class="donate-feature">
              <i class="fas fa-book-open orange"></i>
              <span>#{h(f_recipes)}</span>
            </div>
            <div class="donate-feature">
              <i class="fas fa-shield-alt orange"></i>
              <span>#{h(f_safety)}</span>
            </div>
          </div>

        </div>
      </div>
    </div>

        </div>
  HTML
  page << build_footer(lang)
  page << build_scripts(lang)
  write_file(output_path(lang, "donate.html"), page)
end

# ─────────────────────────────────────────────
# 404 page
# ─────────────────────────────────────────────

def build_404_page(lang)
  prefix = lang_prefix(lang)
  title = t(lang, "page_404", "title")
  description = t(lang, "page_404", "description")
  canonical = "https://www.howtoedibles.com#{prefix}/404.html"
  go_home = t(lang, "page_404", "go_home")
  calculator_label = t(lang, "navbar", "calculator")

  page = build_head(lang, title: title, description: description, canonical: canonical)
  page << build_navbar(lang)
  page << <<~HTML
        <div class="container page-content">
          <div class="error-page text-center">

      <div class="error-illustration">
        <img src="/images/404.png" alt="404" class="error-img" />
      </div>

      <div class="error-actions mt-4">
        <a href="#{prefix}/" class="btn error-btn-primary">#{h(go_home)}</a>
        <a href="#{prefix}/calculator.html" class="btn error-btn-secondary">#{h(calculator_label)}</a>
      </div>

    </div>

        </div>
  HTML
  page << build_footer(lang)
  page << build_scripts(lang)
  write_file(output_path(lang, "404.html"), page)
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
      prefix = lang_prefix(l)
      href = "https://www.howtoedibles.com#{prefix}/#{page}".gsub("//", "/").sub(/\/$/, "/").sub("com//", "com/")
      html_lang = lang_html(l)
      %(    <xhtml:link rel="alternate" hreflang="#{html_lang}" href="#{href}" />)
    end
    xhtml_links << %(    <xhtml:link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/#{page}" />)

    ALL_LANGS.each do |l|
      prefix = lang_prefix(l)
      loc = "https://www.howtoedibles.com#{prefix}/#{page}".gsub("//", "/").sub(/\/$/, "/").sub("com//", "com/")
      urls << "  <url>\n    <loc>#{loc}</loc>\n#{xhtml_links.join("\n")}\n  </url>"
    end
  end

  # Article pages (English only)
  article_files = Dir.glob(File.join(ROOT_DIR, "*.html")).map { |f| File.basename(f) }
  article_files -= %w[index.html calculator.html donate.html 404.html articles.html]
  article_files.sort.each do |f|
    urls << "  <url>\n    <loc>https://www.howtoedibles.com/#{f}</loc>\n  </url>"
  end

  # Recipe pages
  RECIPES.each do |r|
    xhtml_links = ALL_LANGS.map do |l|
      prefix = lang_prefix(l)
      href = "https://www.howtoedibles.com#{prefix}/recipes/#{r["slug"]}/"
      html_lang = lang_html(l)
      %(    <xhtml:link rel="alternate" hreflang="#{html_lang}" href="#{href}" />)
    end
    xhtml_links << %(    <xhtml:link rel="alternate" hreflang="x-default" href="https://www.howtoedibles.com/recipes/#{r["slug"]}/" />)

    ALL_LANGS.each do |l|
      prefix = lang_prefix(l)
      loc = "https://www.howtoedibles.com#{prefix}/recipes/#{r["slug"]}/"
      urls << "  <url>\n    <loc>#{loc}</loc>\n#{xhtml_links.join("\n")}\n  </url>"
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

# ═════════════════════════════════════════════
# BUILD
# ═════════════════════════════════════════════

LANGS.each do |lang|
  puts "\nBuilding #{lang.upcase}..."

  build_homepage(lang)
  puts "  #{lang}/index.html"

  build_calculator_page(lang)
  puts "  #{lang}/calculator.html"

  build_donate_page(lang)
  puts "  #{lang}/donate.html"

  build_404_page(lang)
  puts "  #{lang}/404.html"

  RECIPES.each do |recipe|
    build_recipe_page(recipe, lang)
  end
  puts "  #{lang}/recipes/ (#{RECIPES.count} pages)"
end

puts "\nBuilding sitemap..."
build_sitemap

# Add hreflang tags to English pages (without overwriting content)
puts "\nAdding hreflang tags to English pages..."
english_files = {
  "index.html" => "",
  "calculator.html" => "calculator.html",
  "donate.html" => "donate.html",
  "404.html" => "404.html"
}

english_files.each do |file, page_path|
  filepath = File.join(ROOT_DIR, file)
  next unless File.exist?(filepath)
  content = File.read(filepath)

  # Skip if already has hreflang
  next if content.include?("hreflang")

  tags = hreflang_tags(page_path)
  # Insert after google-site-verification meta tag
  if content.include?("google-site-verification")
    content.sub!(/(<meta name="google-site-verification"[^>]*\/>)/, "\\1\n\n  <!-- hreflang -->\n  #{tags}")
    File.write(filepath, content)
    puts "  Added hreflang to #{file}"
  end
end

# Add hreflang to English recipe pages
Dir.glob(File.join(ROOT_DIR, "recipes", "*", "index.html")).each do |filepath|
  content = File.read(filepath)
  next if content.include?("hreflang")

  slug = File.basename(File.dirname(filepath))
  page_path = "recipes/#{slug}/"
  tags = hreflang_tags(page_path)

  if content.include?("google-site-verification")
    content.sub!(/(<meta name="google-site-verification"[^>]*\/>)/, "\\1\n\n  <!-- hreflang -->\n  #{tags}")
    File.write(filepath, content)
  end
end
puts "  Added hreflang to #{Dir.glob(File.join(ROOT_DIR, "recipes", "*", "index.html")).count} recipe pages"

puts "\nDone! English files preserved. Only /pt/, /es/, /de/ were generated."
