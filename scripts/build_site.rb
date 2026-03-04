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

GA_ID = "UA-90858722-1"
ADSENSE_PUBLISHER = "ca-pub-6354522716906819"
SLOT_LEADERBOARD  = "4353785890"
SLOT_MEDIUM       = "5475295879"

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

def html_head(title:, description:, canonical:, og_image: "https://www.howtoedibles.com/images/pot-brownies.jpg")
  <<~HTML
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
      <title>#{CGI.escapeHTML(title)}</title>
      <meta name="description" content="#{CGI.escapeHTML(description)}" />
      <link rel="canonical" href="#{canonical}" />
      <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico" />

      <!-- Open Graph -->
      <meta property="og:type" content="website" />
      <meta property="og:site_name" content="Edibles Dosage Calculator" />
      <meta property="og:title" content="#{CGI.escapeHTML(title)}" />
      <meta property="og:description" content="#{CGI.escapeHTML(description)}" />
      <meta property="og:image" content="#{og_image}" />
      <meta property="og:url" content="#{canonical}" />

      <!-- Twitter -->
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content="#{CGI.escapeHTML(title)}" />
      <meta name="twitter:description" content="#{CGI.escapeHTML(description)}" />
      <meta name="twitter:image" content="#{og_image}" />

      <meta name="keywords" content="edible dosage calculator, how much weed for edibles, thc calculator, edible, edible potency calculator, edible dosage, cannabutter, pot calculator, cannabis, marijuana, weed, dose, dosage, calculator" />
      <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY" />

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
    <footer class="footer mt-auto">
      <div class="container">
        <div class="row">
          <div class="col-md-6 col-lg-5 mb-md-0">
            <h2 class="footer-heading d-flex align-items-center">Latest News</h2>
            <div class="block-21 mb-4 d-flex highlighted-articles">
              <a href="/how-a-cannabis-calculator-works.html" class="highlight-news-date-icon">
                <i class="mr-3 mt-3 fa fa-lg fa-calculator" aria-hidden="true"></i>
              </a>
              <div class="text">
                <h3 class="heading"><a href="/how-a-cannabis-calculator-works.html" class="hightlight-news-link">How a cannabis calculator works?</a></h3>
                <div class="meta">
                  <a href="/how-a-cannabis-calculator-works.html" class="highlight-news-date">
                    <i class="fa-regular fa-calendar"></i> Aug. 20, 2023
                  </a>
                </div>
              </div>
            </div>
            <div class="block-21 mb-4 d-flex">
              <a href="/how-to-prevent-a-bad-trip.html" class="highlight-news-date-icon">
                <i class="mr-3 mt-3 fa-solid fa-lg fa-square-person-confined"></i>
              </a>
              <div class="text">
                <h3 class="heading"><a href="/how-to-prevent-a-bad-trip.html" class="hightlight-news-link">How to prevent a bad trip?</a></h3>
                <div class="meta">
                  <a href="/how-to-prevent-a-bad-trip.html" class="highlight-news-date highlight-news-date-icon">
                    <i class="fa-regular fa-calendar"></i> Aug. 20, 2023
                  </a>
                </div>
              </div>
            </div>
          </div>
          <div class="col-md-6 col-lg-3 mb-md-0 mb-4">
            <h2 class="footer-heading d-flex align-items-center">Resources</h2>
            <ul class="list-unstyled">
              <li><a href="/how-a-cannabis-calculator-works.html" class="footer-link-section">About</a></li>
              <li class="mt-2"><a href="https://bit.ly/helpimhavingabadtrip" class="footer-link-section">Bad trip chat</a></li>
            </ul>
          </div>
          <div class="col-md-6 col-lg-3 mb-md-0 mb-4">
            <h2 class="footer-heading d-flex align-items-center">Get in touch</h2>
            <ul class="list-unstyled">
              <li><i class="fa-brands fa-instagram"></i> <a href="https://instagram.com/howtoedibles" target="_blank" rel="noopener noreferrer" class="footer-link-section">Instagram</a></li>
              <li class="mt-2"><i class="fa-brands fa-facebook"></i> <a href="https://facebook.com/howtoedibles" target="_blank" rel="noopener noreferrer" class="footer-link-section">Facebook</a></li>
            </ul>
          </div>
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

def html_dosage_widget
  <<~HTML
    <div class="row mt-3">
      <div class="col-sm-12">
        <i class="fa fa-flask fa-lg orange icon-medium" aria-hidden="true"></i>
        <h2>Step 2 - Check your dose</h2>

        <p class="mb-2 mt-3">
          <i class="fa fa-cookie fa-lg green icon-large" aria-hidden="true"></i>
          Full Recipe will have <span class="badge badge-success badge-label badge-label-large" id="potency-result-total">0</span>
        </p>

        <p class="mb-2 mt-3">
          <i class="fa fa-cookie-bite fa-lg green icon-large" aria-hidden="true"></i>
          Each portion will have
          <span class="badge badge-success badge-label" id="potency-result">0</span>
        </p>

        <p id="highness-level" class="mb-2 mt-3"></p>

        <div class="mb-2 mt-5">
          <h2>
            <i class="far fa-laugh fa-lg green icon icon-large" aria-hidden="true"></i>
            Positive Effects
          </h2>
        </div>
        <p class="spaced-content mt-2 pl-2 pb-2" id="positive-effect-details"></p>

        <h2 class="mt-3">
          <i class="far fa-frown fa-lg red icon-large" aria-hidden="true"></i>
          Negative Effects
        </h2>
        <p class="spaced-content mt-3 pl-2 pb-2" id="negative-effect-details"></p>

        <p class="sidenote">You may or may not feel all the effects listed*</p>
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
    #{html_leaderboard_ad}

    <div class="popular-recipes pt-2 pb-2">
      <i class="fa fa-fire-alt fa-lg orange popular-recipe-title icon-medium" aria-hidden="true"></i>
      <h2>Popular recipes</h2>
    </div>

    <div class="row">
      #{all_cards}
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
  img_src     = "#{IMAGE_BASE}/#{slug}.jpg"
  canonical   = "https://www.howtoedibles.com/recipes/#{slug}/"
  og_image    = "https://www.howtoedibles.com#{img_src}"

  title = "How to make #{name} | Edible Dosage Calculator"

  video_html = ""
  if recipe["video"] && !recipe["video"].empty?
    video_html = <<~HTML
      <div class="video-container mt-3">
        <iframe width="100%" height="300px" src="#{recipe["video"]}" frameborder="0" allowfullscreen></iframe>
      </div>
    HTML
  end

  recipe_content = <<~HTML
    <div class="pb-4">
      <div class="recipe-title pb-4">
        <h1>How to make #{CGI.escapeHTML(name)}</h1>
      </div>
      <div class="recipe-content">
        <div class="ingredients-container mb-4">
          <div class="mb-2">
            <i class="fa fa-utensils fa-lg orange icon-medium" aria-hidden="true"></i>
            <h2>Ingredients</h2>
          </div>
          #{recipe["ingredients"]}
        </div>
        <div class="directions-container mb-1">
          <div class="mt-2 mb-2">
            <i class="fa fa-list-ol fa-lg orange icon-medium" aria-hidden="true"></i>
            <h2>Directions</h2>
          </div>
          #{recipe["instructions"]}
        </div>
      </div>
      #{video_html}
    </div>
  HTML

  body = <<~HTML
    <div class="row">
      <div class="col-sm-5 order-2 order-md-2">
        <i class="fa fa-calculator fa-lg orange icon-medium" aria-hidden="true"></i>
        <h2>Step 1 - Calculate</h2>
        #{html_calculator_widget(quantity: quantity, portion: portion, potency: potency)}
        #{html_medium_ad}
        #{html_dosage_widget}
      </div>
      <div class="col-sm-7 order-1 order-md-1">
        #{html_leaderboard_ad}
        #{recipe_content}
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
    description: description,
    canonical:   canonical,
    og_image:    og_image
  )

  page = wrap_page(
    head_content:  head,
    body_content:  body,
    extra_scripts: recipe_defaults_script
  )

  write_file(File.join(SITE_DIR, "recipes", slug, "index.html"), page)
end

def build_calculator_page
  title       = "Edible Dosage Calculator - How Potent Are Your Edibles?"
  description = "Free edible dosage calculator. Find out exactly how many mg of THC are in each portion of your cannabis edibles."
  canonical   = "https://www.howtoedibles.com/calculator.html"

  body = <<~HTML
    #{html_leaderboard_ad}
    <div class="row mt-3">
      <div class="col-sm-5">
        <i class="fa fa-calculator fa-lg orange icon-medium" aria-hidden="true"></i>
        <h2>Step 1 - Calculate</h2>
        #{html_calculator_widget(quantity: 3.5, portion: 50, potency: 14)}
        #{html_medium_ad}
        #{html_dosage_widget}
      </div>
      <div class="col-sm-7">
        <div class="mt-4">
          <h1>Edible Dosage Calculator</h1>
          <p class="mt-3">Use this calculator to find out how potent your cannabis edibles will be. Enter the amount of cannabis, its strength, and the number of portions you plan to make.</p>
          <p>The formula: <strong>P = 10 × (G × S) / N</strong></p>
          <ul>
            <li><strong>G</strong> = grams of cannabis</li>
            <li><strong>S</strong> = strength of cannabis (%)</li>
            <li><strong>N</strong> = number of servings</li>
            <li><strong>P</strong> = potency per serving (mg THC)</li>
          </ul>
          <p><a href="/how-a-cannabis-calculator-works.html">Learn more about how this calculator works →</a></p>
        </div>
      </div>
    </div>
  HTML

  recipe_defaults_script = <<~JS
    <script>
      window.RECIPE_DEFAULTS = { quantity: 3.5, portion: 50, potency: 14 };
    </script>
    <script src="/js/calculator.js"></script>
  JS

  head = html_head(title: title, description: description, canonical: canonical)

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

puts "\nDone! #{RECIPES.count} recipe pages generated."
puts "Serve with: cd static-site && python3 -m http.server 8080"
