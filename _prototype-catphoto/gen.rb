# Throwaway prototype (category photos): takes the real built pages and swaps the category band and the
# menu/homepage tiles for each variant. Usage (repo root): ruby _prototype-catphoto/gen.rb
# Output: _prototype-catphoto/{0,a,b,c}/{lang}-{page}.html — 0 is today's page.
require "json"
ROOT = File.expand_path("..", __dir__)
OUT = __dir__
CATS = JSON.parse(File.read(File.join(ROOT, "data/recipes.json")))["categories"].to_h { |c| [c["slug"], c["name"]] }
# Top 3 recipes per category by impressions (GSC Apr–Nov 2026); the first is the PR #123 share image
TOP = { "Desserts" => %w[pot-brownies gummy-bears pot-cookies],
        "Drinks" => %w[cannabis-cucumber-mint-cooler infused-virgin-mojito infused-whiskey],
        "Snacks" => %w[firecrackers weed-infused-popcorn infused-peanut-butter-banana-bites],
        "Essentials" => %w[cannabutter cannabis-sugar infused-coconut-oil],
        "Lunch" => %w[cannabis-avocado-toast infused-pesto-pasta cannabis-garlic-butter-shrimp],
        "Keto" => %w[infused-coconut-fat-bombs infused-keto-peanut-butter-cookies infused-chocolate-bark],
        "Vegan" => %w[cannabis-vegan-brownies cannabis-vegan-oat-cookies cannabis-coconut-milk-ice-cream],
        "International" => %w[infused-brigadeiro cannabis-churro-bites cannabis-dan-dan-noodles] }
LANGS = %w[en pt de zh]
PAGES = { "desserts" => "category/desserts/index.html", "international" => "category/international/index.html", "home" => "index.html" }
V = %w[0 a b c]
NAMES = { "0" => "Hoje", "a" => "A Janela", "b" => "B Esmaecida", "c" => "C Trio" }
PAGE_NAMES = { "desserts" => "Sobremesas", "international" => "Internacional", "home" => "Home", "menu" => "Menu" }

P = "/images/photos"
def sq(s, extra = ""); %(<img src="#{P}/#{s}-sq-400.webp" width="400" height="400" alt=""#{extra}>); end
LAZY = ' loading="lazy" decoding="async"'

def band(v, cat)
  s = TOP[cat][0]
  case v
  when "a" then %(<img class="pv" src="#{P}/#{s}-sq-400.webp" srcset="#{P}/#{s}-sq-400.webp 400w, #{P}/#{s}-sq-800.webp 800w" sizes="(min-width:1000px) 240px, (min-width:720px) 200px, 150px" width="800" height="800" alt="" fetchpriority="high">)
  when "b" then %(<img class="pv" src="#{P}/#{s}-800.webp" srcset="#{[480, 800, 1200, 1600].map { |w| "#{P}/#{s}-#{w}.webp #{w}w" }.join(", ")}" sizes="(min-width:1000px) 720px, (min-width:720px) 470px, 78vw" width="1600" height="1200" alt="" fetchpriority="high">)
  when "c" then %(<span class="trio">#{TOP[cat].map { |x| sq(x) }.join}</span>)
  end
end

def tile(v, cat)
  case v
  when "a" then sq(TOP[cat][0], %( class="pv"#{LAZY}))
  when "b" then %(<img class="pv" src="#{P}/#{TOP[cat][0]}-480.webp" width="480" height="360" alt=""#{LAZY}>)
  when "c" then %(<span class="trio">#{TOP[cat].map { |x| sq(x, LAZY) }.join}</span>)
  end
end

CSS = {
  # A — one round photo, like a window cut into the colour; the colour stays the tile
  "a" => <<~CSS,
    .band{min-height:252px}
    .band>.pv{position:absolute;right:-20px;top:-20px;width:136px;height:136px;border-radius:50%;object-fit:cover;box-shadow:0 0 0 6px var(--cat-deep)}
    .tiles .cv>.pv{position:absolute;right:-12px;bottom:-12px;width:72px;height:72px;border-radius:50%;object-fit:cover;box-shadow:0 0 0 4px var(--cat-deep)}
    @media (min-width:720px){.band{min-height:260px}.band>.pv{right:32px;top:28px;width:200px;height:200px}}
    @media (min-width:1000px){.band{min-height:290px}.band>.pv{right:56px;top:25px;width:240px;height:240px}}
  CSS
  # B — the photo dissolves into the category colour; text always sits on flat colour
  "b" => <<~CSS,
    .band{min-height:264px}
    .band>.pv{position:absolute;top:0;right:0;width:62%;height:136px;object-fit:cover;
      -webkit-mask-image:linear-gradient(to right,transparent,#000 50%),linear-gradient(to top,transparent,#000 45%);-webkit-mask-composite:source-in;
      mask-image:linear-gradient(to right,transparent,#000 50%),linear-gradient(to top,transparent,#000 45%);mask-composite:intersect}
    .tiles .cv>.pv{position:absolute;top:22%;right:0;width:60%;height:100%;object-fit:cover;
      -webkit-mask-image:linear-gradient(to right,transparent,#000 70%),linear-gradient(to bottom,transparent 12%,#000 50%);-webkit-mask-composite:source-in;
      mask-image:linear-gradient(to right,transparent,#000 70%),linear-gradient(to bottom,transparent 12%,#000 50%);mask-composite:intersect}
    @media (min-width:720px){.band{min-height:260px}.band>.pv{width:52%;height:100%;-webkit-mask-image:linear-gradient(to right,transparent,#000 60%);mask-image:linear-gradient(to right,transparent,#000 60%)}}
    @media (min-width:1000px){.band{min-height:290px}.band>.pv{width:44%}}
  CSS
  # C — three small round photos stacked: reads as "a group of recipes", not one recipe
  "c" => <<~CSS,
    .trio{position:absolute;display:flex}
    .trio img{border-radius:50%;object-fit:cover;box-shadow:0 0 0 4px var(--cat);background:var(--cat-deep)}
    .band>.trio{position:relative;margin:50px 0 0 4px}.band>.trio+h1{margin-top:14px}.band>.trio img{width:60px;height:60px}.band>.trio img+img{margin-left:-14px}
    .tiles .cv,.home .tiles .cv{height:auto;min-height:104px}.tiles .cv>.trio{position:relative;order:3;margin:8px 0 0 3px}.tiles .trio img{width:34px;height:34px;box-shadow:0 0 0 3px var(--cat)}.tiles .trio img+img{margin-left:-9px}
    .tiles .cv{display:flex;flex-direction:column;align-items:flex-start}.tiles .cv>b{order:1}.tiles .cv>small{order:2}
    @media (min-width:720px){.band>.trio{position:absolute;margin:0;right:36px;top:30px}.band>.trio+h1{margin-top:56px}.band>.trio img{width:96px;height:96px}.band>.trio img+img{margin-left:-24px}}
    @media (min-width:1000px){.band{min-height:290px}.band>.trio{right:56px;top:40px}.band>.trio img{width:132px;height:132px;box-shadow:0 0 0 6px var(--cat)}.band>.trio img+img{margin-left:-34px}}
  CSS
}

def toolbar(v, lang, page)
  link = ->(vv, ll, pp, label, on) { %(<a href="../#{vv}/#{ll}-#{pp == "menu" ? "home" : pp}.html#{pp == "menu" ? "?menu" : ""}"#{on ? ' class="on"' : ""}>#{label}</a>) }
  rows = [V.map { |x| link.(x, lang, page, NAMES[x], x == v) },
          PAGE_NAMES.map { |k, n| link.(v, lang, k, n, k == page) },
          LANGS.map { |l| link.(v, l, page, l, l == lang) }]
  <<~HTML
    <div id="pt">#{rows.map { |r| "<div>#{r.join}</div>" }.join}<div><button type="button" onclick="var t=document.documentElement.dataset.theme==='dark'?'light':'dark';localStorage.setItem('theme',t);document.documentElement.dataset.theme=t">tema claro/escuro</button></div></div>
    <style>#pt{position:fixed;left:8px;bottom:8px;z-index:9999;background:#111;color:#fff;font:12px/1.3 system-ui,sans-serif;padding:6px 8px;border-radius:10px;display:grid;gap:4px;max-width:calc(100vw - 16px)}
    #pt div{display:flex;flex-wrap:wrap;gap:4px}#pt a,#pt button{color:#fff;text-decoration:none;padding:2px 6px;border-radius:6px;background:#333;border:0;font:inherit;cursor:pointer}#pt a.on{background:#f27242;color:#111}</style>
    <script>if(/[?&]shot/.test(location.search))document.getElementById("pt").remove();if(/[?&]menu/.test(location.search))addEventListener("load",function(){document.querySelector('[data-open="menu"]').click()})</script>
  HTML
end

LANGS.each do |lang|
  PAGES.each do |page, rel|
    src = File.read(File.join(ROOT, lang == "en" ? rel : "#{lang}/#{rel}"))
    V.each do |v|
      html = src.dup
      if v != "0"
        cat = CATS[page]
        html.sub!(%r{(<section class="band" style="[^"]*">)<svg viewBox="0 0 100 100" aria-hidden="true"><use href="#g-\w+"/></svg>}) { "#{$1}#{band(v, cat)}" } if cat
        n = 0
        html.gsub!(%r{(<a href="[^"]*/category/([a-z]+)/"><span class="cv" style="[^"]*">)<svg viewBox="0 0 100 100" aria-hidden="true"><use href="#g-\w+"/></svg>(?=<b>)}) { n += 1; "#{$1}#{tile(v, CATS.fetch($2))}" }
        abort "no tiles swapped in #{lang}-#{page}" if n < 8
        html.sub!('<link rel="stylesheet" href="/css/site.css">') { |m| "#{m}\n<style>\n#{CSS[v]}</style>" }
      end
      html.sub!("</body>") { "#{toolbar(v, lang, page)}</body>" }
      File.write(File.join(OUT, v, "#{lang}-#{page}.html").tap { |f| Dir.mkdir(File.dirname(f)) unless Dir.exist?(File.dirname(f)) }, html)
    end
  end
end
puts "#{LANGS.size * PAGES.size * V.size} pages in #{OUT}"
