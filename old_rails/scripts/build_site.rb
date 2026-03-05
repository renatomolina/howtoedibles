#!/usr/bin/env ruby
# scripts/build_site.rb
# Standalone build script — no Rails required.
# Run: ruby scripts/build_site.rb
#
# Reads static-site/data/recipes.json and generates all HTML pages.

require "json"
require "fileutils"
require "cgi"

SITE_DIR   = File.expand_path("../static-site", __dir__)
DATA_FILE  = File.join(SITE_DIR, "data", "recipes.json")
IMAGE_BASE = "/images/recipes"

abort "ERROR: #{DATA_FILE} not found. Run: bundle exec rake static:export_recipes" unless File.exist?(DATA_FILE)

data       = JSON.parse(File.read(DATA_FILE))
CATEGORIES = data["categories"]
RECIPES    = data["recipes"]

puts "Building site from #{RECIPES.count} recipes across #{CATEGORIES.count} categories..."

# ─────────────────────────────────────────────
# Helpers
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

def html_head(title:, description:, canonical:, og_image: "#{SITE_URL}/images/pot-brownies.jpg",
              og_type: "website", schema_json: nil, keywords: nil)
  default_keywords = "edible dosage calculator, cannabis edibles, how much weed for edibles, THC calculator, edible potency, marijuana edibles, cannabis dosage, weed edibles"
  kw = keywords ? "#{keywords}, #{default_keywords}" : default_keywords
  schema_tag = schema_json ? "<script type=\"application/ld+json\">\n#{schema_json}\n</script>" : ""
  <<~HTML
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
      <title>#{CGI.escapeHTML(title)}</title>
      <meta name="description" content="#{CGI.escapeHTML(description)}" />
      <link rel="canonical" href="#{canonical}" />
      <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />

      <!-- Open Graph -->
      <meta property="og:type" content="#{og_type}" />
      <meta property="og:site_name" content="HowToEdibles" />
      <meta property="og:title" content="#{CGI.escapeHTML(title)}" />
      <meta property="og:description" content="#{CGI.escapeHTML(description)}" />
      <meta property="og:image" content="#{og_image}" />
      <meta property="og:url" content="#{canonical}" />

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

def html_navbar
  dropdown_items = CATEGORIES.map do |cat|
    recipe_links = cat["recipes"].map do |r|
      "            <a class=\"dropdown-item\" href=\"/recipes/#{r["slug"]}/\">#{CGI.escapeHTML(r["name"])}</a>"
    end.join("\n")

    <<~HTML.chomp
          <li class="nav-item dropdown">
            <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">#{CGI.escapeHTML(cat["name"])}</a>
            <div class="dropdown-menu shadow-sm" role="menu">
    #{recipe_links}
            </div>
          </li>
    HTML
  end.join("\n")

  <<~HTML
    <nav class="navbar navbar-expand-lg navbar-light">
      <div class="container">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarMain" aria-expanded="false" aria-label="Toggle navigation">
          <span class="fa fa-bars navbar-icon"></span>
        </button>
        <a href="/" class="navbar-brand logo-link">
          <img src="/images/howtoedibleslogo.png" alt="How to Edibles" width="180" height="65" />
        </a>
        <!-- Search — always visible, outside collapse -->
        <div class="nav-search-wrapper mx-2">
          <i class="fa fa-search nav-search-icon"></i>
          <input type="search" id="recipe-search" class="nav-search-input" placeholder="Search recipes…" autocomplete="off" />
        </div>
        <div class="collapse navbar-collapse" id="navbarMain">
          <ul class="navbar-nav ml-auto align-items-lg-center">
            <li class="nav-item mr-lg-2">
              <a href="/calculator.html" class="btn btn-nav-calculator">Calculator</a>
            </li>
    #{dropdown_items}
          </ul>
        </div>
      </div>
    </nav>
  HTML
end

def html_footer
  <<~HTML
    <footer class="site-footer mt-auto">
      <div class="container">
        <div class="row footer-main">
          <div class="col-lg-4 col-md-6 mb-4 mb-md-0">
            <a href="/" class="footer-brand">
              <img src="/images/howtoedibleslogo.png" alt="How to Edibles" />
            </a>
            <p class="footer-tagline mt-3">Cannabis edibles made easy. Recipes, dosing calculator, and harm reduction tips.</p>
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
            <h5 class="footer-col-title">Recipes</h5>
            <ul class="footer-links">
              <li><a href="/">All recipes</a></li>
              <li><a href="/calculator.html">Calculator</a></li>
            </ul>
          </div>
          <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">Learn</h5>
            <ul class="footer-links">
              <li><a href="/how-a-cannabis-calculator-works.html">How the calculator works</a></li>
              <li><a href="/how-to-prevent-a-bad-trip.html">How to prevent a bad trip</a></li>
              <li><a href="https://bit.ly/helpimhavingabadtrip" target="_blank" rel="noopener noreferrer">Bad trip support chat</a></li>
              <li><a href="/donate.html">Support us</a></li>
            </ul>
          </div>
          <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
            <h5 class="footer-col-title">Dosage tip</h5>
            <p class="footer-tip"><i class="fa fa-leaf orange mr-2"></i>Start low, go slow. Wait at least 2 hours before taking more.</p>
          </div>
        </div>
        <div class="footer-bottom">
          <p>&copy; #{Time.now.year} HowToEdibles &mdash; For educational purposes only. Always consume responsibly.</p>
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

def html_calculator_widget(quantity:, portion:, potency:)
  <<~HTML
    <div id="calculator-widget">
      <div class="calculator-item pt-1">
        <div class="pb-1">
          <h3>How much weed do you have?</h3>
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
        <h3>How strong is your weed?</h3>
        <div class="average-tip mb-2">
          <span class="bottomtip">(14% average)</span>
          <a class="label-calculator ml-1 mb-1" data-toggle="modal" href="#" data-target="#myModal">
            <span class="badge badge-success">NOT SURE?</span>
          </a>
        </div>
        <input id="strength-slider" type="range"
               min="1" max="99" step="1" value="#{potency}" />

        <!-- Potency reference modal -->
        <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title" id="myModalLabel">Reference for weed potency</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body">
                <table class="modal-potency-table table table-bordered">
                  <thead><tr><th>WEED TYPE</th><th>% (potency)</th></tr></thead>
                  <tbody>
                    <tr><td>Low quality</td><td>5%–10%</td></tr>
                    <tr><td>Medium quality</td><td>10%–15%</td></tr>
                    <tr><td>Top Shelf</td><td>15%–40%</td></tr>
                    <tr><td>Concentrates</td><td>35%–95%</td></tr>
                  </tbody>
                </table>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
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
          <h3>How many portions you want?</h3>
        </div>
        <input id="portion-slider" type="range"
               min="1" max="200" step="1" value="#{portion}" />
        <div class="calculator-control mt-1">
          <a href="#" id="decrease-servings">
            <i class="fa fa-minus-circle fa-lg yellow" aria-hidden="true"></i>
          </a>
          <input id="portion-input" type="number" step="any" class="calculator-input mr-1 ml-1" onchange="updatePortion(this.value)" />
          <span id="portion-label" class="mr-1">portions</span>
          <a href="#" id="increase-servings">
            <i class="fa fa-plus-circle fa-lg green" aria-hidden="true"></i>
          </a>
        </div>
      </div>
    </div>
  HTML
end

def html_dosage_widget_content
  <<~HTML
    <p class="mb-2 mt-2">
      <i class="fa fa-cookie fa-lg green icon-large" aria-hidden="true"></i>
      Full recipe: <span class="badge badge-success badge-label badge-label-large" id="potency-result-total">0</span>
    </p>

    <p class="mb-2 mt-3">
      <i class="fa fa-cookie-bite fa-lg green icon-large" aria-hidden="true"></i>
      Per portion: <span class="badge badge-success badge-label" id="potency-result">0</span>
    </p>

    <p id="highness-level" class="mb-2 mt-3"></p>

    <h3 class="dosage-effects-title mt-4">
      <i class="far fa-laugh green mr-1" aria-hidden="true"></i> Positive Effects
    </h3>
    <p class="spaced-content mt-1 pb-2" id="positive-effect-details"></p>

    <h3 class="dosage-effects-title mt-3">
      <i class="far fa-frown red mr-1" aria-hidden="true"></i> Negative Effects
    </h3>
    <p class="spaced-content mt-1 pb-2" id="negative-effect-details"></p>

    <p class="sidenote mt-2">You may or may not feel all the effects listed*</p>
  HTML
end

def html_dosage_widget
  <<~HTML
    <div class="row mt-3">
      <div class="col-sm-12">
        <i class="fa fa-flask fa-lg orange icon-medium" aria-hidden="true"></i>
        <h2>Step 2 - Check your dose</h2>
        <div class="mt-2">#{html_dosage_widget_content}</div>
      </div>
    </div>
  HTML
end

def wrap_page(head_content:, body_content:, extra_scripts: "")
  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    #{head_content}
      <body>
        #{html_navbar}
        <div class="container page-content">
          #{body_content}
        </div>
        #{html_footer}

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
              if (e.key === 'Enter') { e.preventDefault(); var q = inp.value.trim(); if (q) window.location.href = '/?search=' + encodeURIComponent(q); }
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
  puts "  wrote: #{path.sub(SITE_DIR + "/", "")}"
end

# ─────────────────────────────────────────────
# Page Generators
# ─────────────────────────────────────────────

def build_homepage
  title       = "Edible Dosage Calculator | Cannabutter & Cannabis Recipes"
  description = "Find out how potent your edibles are! This edible dosage calculator helps you cook and dose cannabis edibles responsibly."
  canonical   = "https://www.howtoedibles.com/"

  # Build all recipe cards — single responsive set (works on both desktop and mobile)
  all_cards = RECIPES.map do |r|
    img_src = "#{IMAGE_BASE}/#{r["slug"]}.jpg"
    search_data = CGI.escapeHTML("#{r["name"]} #{r["category_name"]} #{r["description"]}".downcase)
    <<~HTML.strip
      <div class="col-12 col-sm-3 recipe-card-item" data-search="#{search_data}">
        <a href="/recipes/#{r["slug"]}/">
          <div class="card mb-2">
            <img src="#{img_src}" class="card-img-top" alt="#{CGI.escapeHTML(r["name"])}" loading="lazy" />
            <div class="card-block">
              <p class="card-category">#{CGI.escapeHTML(r["category_name"])}</p>
              <p class="card-title">#{CGI.escapeHTML(r["name"])}</p>
              <p class="card-text">#{CGI.escapeHTML(r["description"] || "")}</p>
            </div>
          </div>
        </a>
      </div>
    HTML
  end.join("\n")

  body = <<~HTML
    <div class="homepage-hero mb-4">
      <div class="hero-text">
        <h1 class="hero-title">Cannabis Edibles Recipes</h1>
        <p class="hero-sub">Delicious recipes with a built-in dosage calculator so you always know what's in your food.</p>
      </div>
    </div>

    <div class="section-header mb-3">
      <i class="fa fa-fire-alt orange mr-2" aria-hidden="true"></i>
      <span>Popular recipes</span>
    </div>

    <div class="row">
      #{all_cards}
    </div>

    <div class="donate-cta">
      <i class="fas fa-heart donate-cta-icon"></i>
      <div class="donate-cta-text">
        <strong>Enjoying the recipes?</strong> This site is free and ad-light — help us keep it that way.
      </div>
      <a href="/donate.html" class="donate-cta-btn">Support us</a>
    </div>

    <div id="search-no-results">No recipes found. Try a different search.</div>
    <div id="pagination-controls" class="mt-3 mb-4"></div>
  HTML

  head = html_head(
    title:       title,
    description: description,
    canonical:   canonical,
    og_image:    "https://www.howtoedibles.com/images/pot-brownies.jpg"
  )

  page = wrap_page(
    head_content:  head,
    body_content:  body,
    extra_scripts: '<script src="/js/homepage.js"></script>'
  )

  write_file(File.join(SITE_DIR, "index.html"), page)
end

def build_recipe_page(recipe)
  slug        = recipe["slug"]
  name        = recipe["name"]
  quantity    = recipe["suggested_quantity"]  || 3.5
  portion     = recipe["suggested_portion"]   || 50
  potency     = 14
  description = recipe["description"] || ""
  category    = recipe["category_name"] || ""
  img_src     = "#{IMAGE_BASE}/#{slug}.jpg"
  canonical   = "https://www.howtoedibles.com/recipes/#{slug}/"
  og_image    = "https://www.howtoedibles.com#{img_src}"

  title       = "#{name} Cannabis Edibles Recipe | HowToEdibles"
  title       = title[0, 60] + "…" if title.length > 62  # keep under 62 chars

  # ── Structured data ──────────────────────────────────────
  ingredients_list = extract_li_texts(recipe["ingredients"] || "")
  instructions_list = extract_li_texts(recipe["instructions"] || "")
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
      { "@type" => "ListItem", "position" => 1, "name" => "Home",     "item" => "#{SITE_URL}/" },
      { "@type" => "ListItem", "position" => 2, "name" => category,   "item" => "#{SITE_URL}/" },
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
        <span>Ingredients</span>
      </div>
      <div class="recipe-section-body">
        #{recipe["ingredients"]}
      </div>
    </div>

    <div class="recipe-section-card mb-4">
      <div class="recipe-section-header">
        <i class="fa fa-list-ol" aria-hidden="true"></i>
        <span>Directions</span>
      </div>
      <div class="recipe-section-body recipe-steps">
        #{recipe["instructions"]}
      </div>
    </div>

    #{video_html}
  HTML

  calculator_col = <<~HTML
    <div class="calculator-panel mb-3">
      <div class="calculator-panel-header">
        <i class="fa fa-calculator" aria-hidden="true"></i>
        <span>Calculate Your Dose</span>
      </div>
      <div class="calculator-panel-body">
        #{html_calculator_widget(quantity: quantity, portion: portion, potency: potency)}
      </div>
    </div>

    <div class="dosage-panel">
      <div class="dosage-panel-header">
        <i class="fa fa-flask" aria-hidden="true"></i>
        <span>Check Your Dose</span>
      </div>
      <div class="dosage-panel-body">
        #{html_dosage_widget_content}
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

  # Inject RECIPE_DEFAULTS before calculator.js
  recipe_defaults_script = <<~JS
    <script>
      window.RECIPE_DEFAULTS = { quantity: #{quantity}, portion: #{portion}, potency: #{potency} };
    </script>
    <script src="/js/calculator.js"></script>
  JS

  head = html_head(
    title:       title,
    description: description.empty? ? "Learn how to make cannabis #{name} with our step-by-step recipe and built-in THC dosage calculator." : description,
    canonical:   canonical,
    og_image:    og_image,
    og_type:     "article",
    schema_json: schema_json,
    keywords:    keywords
  )

  page = wrap_page(
    head_content:  head,
    body_content:  body,
    extra_scripts: recipe_defaults_script
  )

  write_file(File.join(SITE_DIR, "recipes", slug, "index.html"), page)
end

def build_calculator_page
  title       = "Edible Dosage Calculator — Calculate THC mg Per Serving | HowToEdibles"
  description = "Free cannabis edible dosage calculator. Enter your weed amount, potency %, and number of servings to instantly find mg of THC per portion. Start low, go slow."
  canonical   = "#{SITE_URL}/calculator.html"

  # ── FAQ data (also powers FAQPage schema) ────────────────
  faqs = [
    {
      q: "How many mg of THC should a beginner take in an edible?",
      a: "Beginners should start with 2.5–5 mg of THC. This is a microdose that produces mild effects without overwhelming anxiety. Wait at least 2 hours before taking more, as edibles take longer to kick in than smoking."
    },
    {
      q: "How long do edibles take to kick in?",
      a: "Cannabis edibles typically take 30 minutes to 2 hours to kick in, depending on your metabolism, body weight, and whether you've eaten recently. The effects can last 4–8 hours, much longer than smoking."
    },
    {
      q: "How do you calculate the dosage of cannabis edibles?",
      a: "Use the formula: P = 10 × (G × S) / N, where G = grams of cannabis, S = potency percentage, N = number of servings, and P = mg of THC per serving. For example, 3.5g of 20% cannabis divided into 20 servings = 35 mg each."
    },
    {
      q: "Why are edibles stronger than smoking weed?",
      a: "When you eat cannabis, your liver converts THC into 11-hydroxy-THC, a more potent compound that crosses the blood-brain barrier more effectively. This makes edibles significantly stronger and longer-lasting than inhaled THC."
    },
    {
      q: "What happens if you eat too many edibles?",
      a: "Overconsumption of cannabis edibles can cause intense anxiety, paranoia, rapid heartbeat, and disorientation. These effects are temporary and not life-threatening. If this happens: stay calm, drink water, lie down in a comfortable place, and remember the feeling will pass. Use our calculator before consuming to avoid this."
    },
    {
      q: "Does the amount of butter or oil matter for edible potency?",
      a: "No. The potency of your edibles depends only on the amount of cannabis used, its THC percentage, and the number of servings. The quantity of butter or oil you use affects texture, not potency. Our calculator reflects this exactly."
    }
  ]

  # ── WebApplication + FAQPage schemas ─────────────────────
  webapp_schema = {
    "@context"            => "https://schema.org",
    "@type"               => "WebApplication",
    "name"                => "Cannabis Edible Dosage Calculator",
    "url"                 => canonical,
    "description"         => description,
    "applicationCategory" => "HealthApplication",
    "operatingSystem"     => "Any",
    "browserRequirements" => "Requires JavaScript",
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

  # ── Popular recipes for internal linking ──────────────────
  featured_slugs = %w[cannabutter pot-brownies pot-cookies gummy-bears infused-coconut-oil infused-lemonade]
  featured = RECIPES.select { |r| featured_slugs.include?(r["slug"]) }
  recipe_links = featured.map do |r|
    "<a href=\"/recipes/#{r["slug"]}/\" class=\"calc-recipe-chip\">#{CGI.escapeHTML(r["name"])}</a>"
  end.join("\n")

  # ── Dosage guide rows ─────────────────────────────────────
  dosage_rows = [
    ["Microdose",    "1–2.5 mg",   "No or barely noticeable effect. Good for first-timers.",           "table-success"],
    ["Beginner",     "2.5–5 mg",   "Mild relaxation, light euphoria. Ideal starting dose.",            "table-success"],
    ["Casual",       "5–15 mg",    "Clear euphoria, altered perception. Common recreational dose.",     ""],
    ["Experienced",  "15–30 mg",   "Strong effects, may cause anxiety in low-tolerance users.",         "table-warning"],
    ["High dose",    "30–50 mg",   "Very intense. Recommended only for high-tolerance users.",          "table-warning"],
    ["Extreme",      "50+ mg",     "Overwhelming for most people. Medical patients only.",              "table-danger"],
  ]

  dosage_table_rows = dosage_rows.map do |level, dose, effect, cls|
    "<tr class=\"#{cls}\"><td><strong>#{level}</strong></td><td>#{dose}</td><td>#{effect}</td></tr>"
  end.join("\n")

  # ── FAQ HTML ──────────────────────────────────────────────
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

  # ── Right column rich content ─────────────────────────────
  content_col = <<~HTML
    <article class="calc-info-col">
      <h1 class="calc-page-title">Cannabis Edible Dosage Calculator</h1>
      <p class="calc-page-intro">
        Use this free calculator to find out exactly how many <strong>milligrams of THC</strong> are in each portion of your cannabis edibles — before you cook. Enter your cannabis amount, strength, and number of servings. Instant, accurate results.
      </p>

      <h2 class="calc-section-title mt-4">THC Dosage Guide</h2>
      <p class="calc-section-sub">How many mg is the right dose for you?</p>
      <div class="table-responsive mb-4">
        <table class="table table-sm calc-dosage-table">
          <thead>
            <tr><th>Level</th><th>THC per serving</th><th>Expected effects</th></tr>
          </thead>
          <tbody>
            #{dosage_table_rows}
          </tbody>
        </table>
      </div>

      <h2 class="calc-section-title">How to Use the Calculator</h2>
      <ol class="calc-steps-list">
        <li>Enter the <strong>grams of cannabis</strong> you plan to use.</li>
        <li>Set the <strong>THC percentage</strong> (check your dispensary label, or use the "Not sure?" guide).</li>
        <li>Enter the <strong>number of servings</strong> your recipe makes.</li>
        <li>The calculator instantly shows <strong>mg THC per serving</strong> and total potency.</li>
      </ol>
      <p class="mt-2"><a href="/how-a-cannabis-calculator-works.html">How does the math work? →</a></p>

      <h2 class="calc-section-title mt-4">Try It With a Recipe</h2>
      <p class="calc-section-sub">Open any recipe to pre-fill the calculator with suggested amounts:</p>
      <div class="calc-recipe-chips mb-4">
        #{recipe_links}
        <a href="/" class="calc-recipe-chip calc-recipe-chip--more">All recipes →</a>
      </div>

      <h2 class="calc-section-title mt-4">Frequently Asked Questions</h2>
      <div class="calc-faq">
        #{faq_items}
      </div>

      <p class="sidenote mt-4">
        <i class="fa fa-shield-alt orange mr-1"></i>
        Always start low and go slow. Wait at least 2 hours before taking more. This calculator is for educational purposes only.
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
            <span>Calculate Your Dose</span>
          </div>
          <div class="calculator-panel-body">
            #{html_calculator_widget(quantity: 3.5, portion: 50, potency: 14)}
          </div>
        </div>
        <div class="dosage-panel">
          <div class="dosage-panel-header">
            <i class="fa fa-flask" aria-hidden="true"></i>
            <span>Check Your Dose</span>
          </div>
          <div class="dosage-panel-body">
            #{html_dosage_widget_content}
          </div>
        </div>
      </div>
      <div class="col-md-7 recipe-left-col">
        #{content_col}
      </div>
    </div>
  HTML

  recipe_defaults_script = <<~JS
    <script>
      window.RECIPE_DEFAULTS = { quantity: 3.5, portion: 50, potency: 14 };
    </script>
    <script src="/js/calculator.js"></script>
    #{faq_toggle_script}
  JS

  head = html_head(
    title:       title,
    description: description,
    canonical:   canonical,
    keywords:    "edible dosage calculator, THC mg calculator, cannabis edible potency, how to dose edibles, weed edible calculator, marijuana edibles calculator",
    schema_json: schema_json
  )

  page = wrap_page(
    head_content:  head,
    body_content:  body,
    extra_scripts: recipe_defaults_script
  )

  write_file(File.join(SITE_DIR, "calculator.html"), page)
end

def build_404_page
  head = html_head(
    title:       "Page Not Found | HowToEdibles",
    description: "Sorry, that page could not be found.",
    canonical:   "https://www.howtoedibles.com/404.html"
  )

  body = <<~HTML
    <div class="text-center mt-5 mb-5">
      <h1>404</h1>
      <p class="spaced-subtitle">Sorry, that page could not be found.</p>
      <a href="/" class="btn btn-success">Go to Home</a>
    </div>
  HTML

  page = wrap_page(head_content: head, body_content: body)
  write_file(File.join(SITE_DIR, "404.html"), page)
end

def build_donate_page
  head = html_head(
    title:       "Support HowToEdibles | Donate",
    description: "Help us keep HowToEdibles free. If this site has been useful, consider making a small donation.",
    canonical:   "https://www.howtoedibles.com/donate.html"
  )

  body = <<~HTML
    <div class="donate-page">
      <div class="row justify-content-center">
        <div class="col-md-7 col-lg-6">

          <div class="donate-hero text-center">
            <div class="donate-icon">
              <i class="fas fa-heart"></i>
            </div>
            <h1 class="donate-title">Support HowToEdibles</h1>
            <p class="donate-subtitle">This website is free and always will be. If it has helped you, consider buying us a coffee.</p>
          </div>

          <div class="donate-card">
            <p>We put a lot of work into making cannabis edibles safe, fun and accessible. The dosage calculator, the recipes, the harm reduction guides — everything is free and ad-light.</p>
            <p>Running a website has costs. If you've found value here, even a small contribution helps us keep the lights on and add new content.</p>

            <div class="text-center mt-4 mb-3">
              <a href="https://bit.ly/donateht" target="_blank" rel="noopener noreferrer" class="btn-donate">
                <i class="fas fa-heart mr-2"></i> Donate via PayPal
              </a>
            </div>

            <p class="donate-note">Every contribution, big or small, is genuinely appreciated. Thank you for being part of this community.</p>
          </div>

          <div class="donate-features">
            <div class="donate-feature">
              <i class="fas fa-calculator orange"></i>
              <span>Free dosage calculator for everyone</span>
            </div>
            <div class="donate-feature">
              <i class="fas fa-book-open orange"></i>
              <span>41+ tested cannabis recipes</span>
            </div>
            <div class="donate-feature">
              <i class="fas fa-shield-alt orange"></i>
              <span>Harm reduction guides &amp; safety tips</span>
            </div>
          </div>

        </div>
      </div>
    </div>
  HTML

  page = wrap_page(head_content: head, body_content: body)
  write_file(File.join(SITE_DIR, "donate.html"), page)
end

# ─────────────────────────────────────────────
# Main Build
# ─────────────────────────────────────────────

puts "\n--- Building homepage ---"
build_homepage

puts "\n--- Building recipe pages ---"
RECIPES.each { |r| build_recipe_page(r) }

puts "\n--- Building calculator page ---"
build_calculator_page

puts "\n--- Building 404 page ---"
build_404_page

puts "\n--- Building donation page ---"
build_donate_page

puts "\nDone! #{RECIPES.count} recipe pages generated."
puts "Serve with: cd static-site && python3 -m http.server 8080"
