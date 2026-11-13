# scripts/build_redesign.rb — the redesign's shell and page templates (#72 Phase 1a, #73 Phase 1b, #74 Phase 2).
# Loaded by build_site.rb, which owns the data loading and the old-shell builders that the
# pages not yet migrated still use. Phase 4 (#76) deletes the old shell; this file stays.

require "set"

# ─────────────────────────────────────────────
# Data
# ─────────────────────────────────────────────

CAT_ORDER = %w[Desserts Drinks Snacks Essentials Lunch Keto Vegan International].freeze
CAT_BY_NAME = CATEGORIES.to_h { |c| [c["name"], c] }
CAT_GLYPH = { "Desserts" => "cake", "Drinks" => "glass", "Snacks" => "chips", "Essentials" => "butter",
              "Lunch" => "bowl", "Keto" => "egg", "Vegan" => "salad", "International" => "dumpling" }.freeze
# Share image of each category page: the photo of its most-impressed recipe (GSC Apr–Nov 2026, all languages)
CAT_OG = { "Desserts" => "pot-brownies", "Drinks" => "cannabis-cucumber-mint-cooler", "Snacks" => "firecrackers",
           "Essentials" => "cannabutter", "Lunch" => "cannabis-avocado-toast", "Keto" => "infused-coconut-fat-bombs",
           "Vegan" => "cannabis-vegan-brownies", "International" => "infused-brigadeiro" }.freeze
# Group by category_name: recipes.json → categories[].recipes is stale (137 of 237).
RECIPES_BY_CAT = CAT_ORDER.to_h { |c| [c, RECIPES.select { |r| r["category_name"] == c }.sort_by { |r| [r["position"].to_i, r["id"].to_i] }] }
abort "ERROR: recipes outside the 8 categories" unless RECIPES_BY_CAT.values.sum(&:size) == RECIPES.size
POPULAR = %w[cannabutter pot-brownies gummy-bears pot-cookies infused-coconut-oil].freeze # ponytail: placeholder until GSC/GA4 says what's most made
LEARN = %w[cannabis-edibles-for-beginners how-long-do-edibles-take-to-kick-in science-of-decarboxylation how-to-prevent-a-bad-trip].freeze
HELP_URL = "https://bit.ly/helpimhavingabadtrip"
SITE = "https://www.howtoedibles.com"
LANG_LABEL = { "en" => "EN", "pt" => "PT", "es" => "ES", "de" => "DE", "zh" => "中文" }.freeze
AD_CLIENT = "ca-pub-6354522716906819"
# One AdSense unit per position (#55), named like the key, so the Ad units report says which position earns.
# The same units serve all 5 languages.
AD_UNITS = { "recipe-mid" => "5319493367", "recipe-end" => "6436153975", "category" => "8412735570",
              "home" => "3151515085", "calc-mid" => "3809990635", "calc-end" => "3543552279",
              "article-mid" => "2038723901", "article-end" => "9534245553" }.freeze

SPRITE = File.read(File.join(ROOT_DIR, "data", "glyphs.svg")).sub(/\A.*?<svg[^>]*>/m, "").sub(%r{</svg>\s*\z}, "").gsub(/<!--.*?-->\n?/m, "").strip

# The logo (scripts/build_logo.py) as one <symbol>: HOW TO is the only part that changes in dark mode
# (logo.svg vs logo-dark.svg), so it takes var(--ink) and one symbol serves both themes. Its orange and green
# become --logo-o/--logo-g (defaulting to the logo's own colours), so a cover colour can turn it all ink.
def logo_symbol
  light = File.read(File.join(ROOT_DIR, "images/brand/logo.svg"))
  dark = File.read(File.join(ROOT_DIR, "images/brand/logo-dark.svg"))
  view_box = light[/viewBox="([^"]+)"/, 1]
  a, b = light.split(/(?=<)/), dark.split(/(?=<)/)
  abort "ERROR: logo.svg and logo-dark.svg differ in structure" unless a.size == b.size
  body = a.zip(b).map { |x, y| x == y ? x : x.sub(/fill="[^"]+"/, 'fill="var(--ink)"') }.join
  body = body.gsub(/(fill|stroke)="(#f5821f)"/) { %(#{$1}="var(--logo-o,#{$2})") }.gsub(/fill="(#79ab47)"/) { %(fill="var(--logo-g,#{$1})") }
  inner = body.sub(/\A.*?<svg[^>]*>/m, "").sub(%r{</svg>\s*\z}, "")
  %(<symbol id="logo" viewBox="#{view_box}">#{inner.strip}</symbol>)
end
LOGO_SYMBOL = logo_symbol
_, _, lw, lh = LOGO_SYMBOL[/viewBox="([^"]+)"/, 1].split.map(&:to_f)
LOGO_H = (240 * lh / lw).round # the <svg> height for a 240-wide logo; CSS keeps the same ratio (.logo aspect-ratio)
SPRITE_HTML = %(<svg xmlns="http://www.w3.org/2000/svg" style="display:none">#{SPRITE}#{LOGO_SYMBOL}</svg>)

ICON = {
  search: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
  menu: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h10"/></svg>',
  x: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>',
  arr: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>',
  calc: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="3" width="14" height="18" rx="3"/><path d="M8.5 7.5h7M9 12h.01M12 12h.01M15 12h.01M9 15.5h.01M12 15.5h.01M15 15.5h.01"/></svg>',
  life: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4"/><path d="m5.6 5.6 3.6 3.6M14.8 14.8l3.6 3.6M18.4 5.6l-3.6 3.6M9.2 14.8l-3.6 3.6"/></svg>',
  down: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M6 13l6 6 6-6"/></svg>',
  dial: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h10M18 7h2M4 17h4M12 17h8"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="17" r="2"/></svg>',
  warn: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7.5v5.5M12 16.5h.01"/></svg>',
  plus: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>',
  minus: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 12h12"/></svg>',
  sun: '<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>',
}.freeze

# ─────────────────────────────────────────────
# Strings and numbers
# ─────────────────────────────────────────────

# i18n/{lang}.json → ui.group.key, with {x} placeholders; {x|lower} lowercases (en/pt/es strings use it).
def ui(lang, key, vars = {})
  s = t(lang, "ui", *key.split("."))
  return s unless s.is_a?(String)
  s.gsub(/\{(\w+)(\|lower)?\}/) { v = vars.fetch($1.to_sym).to_s; $2 ? v.downcase : v }
end

def servings_word(lang, n); ui(lang, n == 1 ? "calc.serving" : "calc.servings"); end
def rname(r, lang); recipe_t(lang, r["slug"], "name") || r["name"]; end

# Intl.NumberFormat(lang, {maximumFractionDigits: d}), so the static HTML matches what dose.js prints.
def nf(v, d, lang)
  s = format("%.#{d}f", v.to_f.round(d))
  s = s.sub(/\.?0+\z/, "") if d.positive?
  int, frac = s.split(".")
  group = { "en" => ",", "zh" => ",", "pt" => ".", "de" => "." , "es" => "." }[lang]
  min_group = lang == "es" ? 5 : 4 # es only groups from 10 000
  int = int.reverse.scan(/\d{1,3}/).join(group).reverse if int.length >= min_group
  dec = %w[pt es de].include?(lang) ? "," : "."
  frac ? "#{int}#{dec}#{frac}" : int
end
def fmt_mg(mg, lang); nf(mg, mg >= 10 ? 0 : 1, lang); end
def fmt_g(g, lang); nf(g, g < 1 ? 2 : 1, lang); end

# ─────────────────────────────────────────────
# Dose: one formula, one ladder, one 5 mg helper (mirrored in js/dose.js — keep them in sync)
# ─────────────────────────────────────────────

LEVELS = [["microdose", 0, 2.5], ["beginner", 2.5, 5], ["casual", 5, 15], ["experienced", 15, 30], ["high", 30, 50], ["extreme", 50, 80]].freeze
RANGES = ["1–2.5 mg", "2.5–5 mg", "5–15 mg", "15–30 mg", "30–50 mg", "50+ mg"].freeze
LEVEL_COLORS = %w[#8fd6a9 #5cc48a #f4c542 #f29a42 #f27242 #d9412b].freeze
FRACS = [[1 / 2r, "½", "半"], [1 / 3r, "⅓", "三分之一"], [1 / 4r, "¼", "四分之一"], [1 / 6r, "⅙", "六分之一"],
         [1 / 8r, "⅛", "八分之一"], [1 / 10r, "1/10", "十分之一"], [1 / 12r, "1/12", "十二分之一"]].freeze
DEFAULT_THC = 14

def mg_of(g, s, n); 10.0 * g * s * COOKING_EFFICIENCY / n; end
def default_mg(r); mg_of(r["suggested_quantity"].to_f, DEFAULT_THC, r["suggested_portion"].to_f); end
def lvl_idx(mg); LEVELS.index { |l| mg <= l[2] } || 5; end

# Largest of ½ ⅓ ¼ ⅙ ⅛ 1/10 1/12 that keeps the piece ≤ 5 mg (rounds down).
def five_mg(mg, lang)
  return { one: true } if mg <= 5
  f = FRACS.find { |v, _, _| v <= 5 / mg }
  f ? { f: lang == "zh" ? f[2] : f[1], mg: mg * f[0] } : { too_strong: true }
end

def beginner_href(lang); learn_href(lang, "cannabis-edibles-for-beginners"); end

def newbie_html(lang, mg)
  x = five_mg(mg, lang)
  line = if x[:one] then ui(lang, "recipe.newbie_one")
         elsif x[:too_strong] then ui(lang, "recipe.newbie_too_strong")
         else ui(lang, "recipe.newbie", f: x[:f], mg: fmt_mg(x[:mg], lang))
         end
  %(#{line} <a href="#{beginner_href(lang)}">#{h(ui(lang, "calc.beginner_link"))}</a>)
end

def split_html(lang, g, s, n)
  mg = mg_of(g, s, n)
  x = five_mg(mg, lang)
  return "" if x[:one]
  cut = %(<small>#{h(ui(lang, "calc.cut", n: (10 * g * s * COOKING_EFFICIENCY / 5).ceil))}</small>)
  x[:f] ? %(<p class="split">#{ui(lang, "calc.split", f: x[:f], t: nf(5, 1, lang))}#{cut}</p>) : %(<p class="split bad">#{h(ui(lang, "calc.too_strong"))}#{cut}</p>)
end

def live_html(lang, g, s, n)
  mg = mg_of(g, s, n)
  i = lvl_idx(mg)
  lo, hi = LEVELS[i][1], LEVELS[i][2]
  pos = ((i + [[(mg - lo) / (hi - lo), 0].max, 1].min) / 6.0 * 100).round(2)
  key = "dosage_#{LEVELS[i][0]}"
  ladder = (0..5).map { |j| j == i ? %(<i class="on"></i>) : "<i></i>" }.join
  %(<div class="big"><div><span class="mg">#{fmt_mg(mg, lang)}<small> mg</small></span><span class="lbl">#{h(ui(lang, "calc.per"))}</span></div>) +
    %(<div class="tot"><b>#{fmt_mg(mg * n, lang)} mg</b>#{h(ui(lang, "calc.batch"))}</div></div>) +
    %(<div class="lad" aria-hidden="true">#{ladder}<span class="mk" style="left:#{pos}%"></span></div>) +
    %(<div class="lvl"><b>#{h(t(lang, "calculator", key))}</b><span>#{RANGES[i]} · #{h(t(lang, "calculator", "#{key}_desc"))}</span></div>) +
    split_html(lang, g, s, n)
end

def peek_html(lang, g, s, n)
  mg = mg_of(g, s, n)
  %(<b>#{fmt_mg(mg, lang)}<small> mg</small></b><span>#{h(t(lang, "calculator", "dosage_#{LEVELS[lvl_idx(mg)][0]}"))}) +
    %(<small>#{h(ui(lang, "calc.per"))} · #{h(ui(lang, "calc.in_batch", mg: fmt_mg(mg * n, lang)))}</small></span>)
end

# Strings dose.js needs to re-render the panel, peek, sticker and hero lines live.
def dose_strings(lang)
  levels = LEVELS.map { |l| [t(lang, "calculator", "dosage_#{l[0]}"), t(lang, "calculator", "dosage_#{l[0]}_desc")] }
  raw = ->(k) { t(lang, "ui", *k.split(".")) }
  { per: raw["calc.per"], batch: raw["calc.batch"], inBatch: raw["calc.in_batch"], serving: raw["calc.serving"], servings: raw["calc.servings"],
    adjustSub: raw["recipe.adjust_sub"], newbie: raw["recipe.newbie"], newbieOne: raw["recipe.newbie_one"], newbieTooStrong: raw["recipe.newbie_too_strong"],
    begLink: %( <a href="#{beginner_href(lang)}">#{h(ui(lang, "calc.beginner_link"))}</a>), split: raw["calc.split"], cut: raw["calc.cut"],
    tooStrong: raw["calc.too_strong"], wake: raw["recipe.wake"], wakeOn: raw["recipe.wake_on"], levels: levels }
end

# ─────────────────────────────────────────────
# Covers: colour block + dish-form glyph, placed by a slug seed (same seed as the prototypes)
# ─────────────────────────────────────────────

def seeded(slug)
  m = 0xffffffff
  h = 2166136261
  slug.each_char { |c| h = ((h ^ c.ord) * 16777619) & m }
  ->(n) { h = ((((h ^ (h >> 15)) * 2246822507) & m) ^ n) & m; h / 4294967296.0 }
end

def place(slug, kind)
  r = seeded(slug)
  case kind
  when :hero then { gh: "#{(124 + r.(1) * 22).round(1)}%", gs: "auto", gx: "#{(-2 - r.(2) * 10).round(1)}%", gy: "#{(-22 - r.(3) * 22).round(1)}%", gr: "#{(-18 + r.(4) * 28).round(1)}deg" }
  when :tile then { gs: "84%", gx: "-14%", gy: "-34%", gr: "#{(-16 + r.(4) * 20).round(1)}deg" }
  when :thumb then {}
  else { gs: "#{(90 + r.(1) * 14).round(1)}%", gx: "#{(-12 - r.(2) * 16).round(1)}%", gy: "#{(-12 - r.(3) * 16).round(1)}%", gr: "#{(-20 + r.(4) * 30).round(1)}deg" }
  end
end

def cat_vars(cat)
  c = CAT_BY_NAME.fetch(cat)["colors"]
  "--cat-lt:#{c["cover"]};--deep-lt:#{c["glyph"]};--cat-dk:#{c["cover_dark"]};--deep-dk:#{c["glyph_dark"]}"
end

def glyph_svg(g); %(<svg viewBox="0 0 100 100" aria-hidden="true"><use href="#g-#{g}"/></svg>); end

def cover(slug, cat, glyph, kind, inner = "", alt: "")
  return %(<span class="cv ph" style="#{cat_vars(cat)}">#{photo_img(slug, kind, alt)}#{inner}</span>) if %i[hero card].include?(kind) && PHOTOS[slug]
  style = [cat_vars(cat), *place(slug, kind).map { |k, v| "--#{k}:#{v}" }].join(";")
  %(<span class="cv" style="#{style}">#{glyph_svg(glyph)}#{inner}</span>)
end

# ─────────────────────────────────────────────
# Recipe photos (#57 §7): a reviewed master at images/photos/<slug>.jpg replaces the cover on the hero,
# the cards and the schema image, if it passes the gate (≥ 1600 wide, aspect 1.25–1.40). Otherwise the
# cover stays. Derivatives are built here with ImageMagick, only when missing or older than the master.
# ─────────────────────────────────────────────

PHOTO_DIR = File.join(ROOT_DIR, "images", "photos")
PHOTO_W = [480, 800, 1200, 1600]  # 4:3 hero
PHOTO_SQ = [400, 800]             # 1:1 cards
HERO_MAX_BYTES = 25_000           # cap for the 800 hero (mobile LCP)
SCHEMA_CROPS = { "1x1" => [1200, 1200], "4x3" => [1200, 900], "16x9" => [1200, 675] } # Google's Recipe ratios

PHOTOS = Hash.new do |memo, slug|
  src = File.join(PHOTO_DIR, "#{slug}.jpg")
  memo[slug] = File.file?(src) && build_photo(slug, src)
end

def build_photo(slug, src)
  w, h = IO.popen(["magick", "identify", "-format", "%w %h", src], &:read).split.map(&:to_i)
  unless w >= 1600 && (1.25..1.40).cover?(w.to_f / h)
    warn "  photo gate FAIL #{slug}: #{w}x#{h}, cover kept"
    return false
  end
  outs = PHOTO_W.map { |x| ["#{slug}-#{x}.webp", x, x * 3 / 4, 78] } +
         PHOTO_SQ.map { |x| ["#{slug}-sq-#{x}.webp", x, x, 78] } +
         SCHEMA_CROPS.map { |k, (cw, ch)| ["#{slug}-#{k}.jpg", cw, ch, 85] }
  outs.each do |name, ow, oh, q|
    out = File.join(PHOTO_DIR, name)
    next if File.file?(out) && File.mtime(out) >= File.mtime(src)
    enc = ->(*opt) { system("magick", src, "-resize", "#{ow}x#{oh}^", "-gravity", "center", "-extent", "#{ow}x#{oh}", "-strip", *opt, out) }
    abort "ERROR: magick failed on #{name}" unless enc.("-quality", q.to_s)
    # The 800 hero is the mobile LCP image; busy photos pass 25 KB at q78 and sit at the 1.8 s lab gate
    if name == "#{slug}-800.webp" && File.size(out) > HERO_MAX_BYTES
      abort "ERROR: magick failed on #{name}" unless enc.("-define", "webp:target-size=#{HERO_MAX_BYTES - 1000}")
    end
  end
  true
end

def photo_img(slug, kind, alt)
  base = "/images/photos/#{slug}"
  if kind == :hero
    set = PHOTO_W.map { |x| "#{base}-#{x}.webp #{x}w" }.join(", ")
    %(<img src="#{base}-800.webp" srcset="#{set}" sizes="(min-width:1000px) 760px, 100vw" width="1600" height="1200" alt="#{h(alt)}" fetchpriority="high">)
  else
    set = PHOTO_SQ.map { |x| "#{base}-sq-#{x}.webp #{x}w" }.join(", ")
    %(<img src="#{base}-sq-400.webp" srcset="#{set}" sizes="(min-width:720px) 240px, 46vw" width="800" height="800" alt="" loading="lazy" decoding="async">)
  end
end

def schema_image(slug)
  PHOTOS[slug] ? SCHEMA_CROPS.keys.map { |k| "#{SITE}/images/photos/#{slug}-#{k}.jpg" } : "#{SITE}/schema/#{slug}.png"
end

def cat_url(lang, cat); "#{lang_prefix(lang)}/category/#{CAT_BY_NAME.fetch(cat)["slug"]}/"; end
def recipe_url(lang, r); "#{lang_prefix(lang)}/recipes/#{r["slug"]}/"; end

def card(r, lang)
  mg = fmt_mg(default_mg(r), lang)
  dot = %(<span class="dot" title="#{mg} mg THC #{h(ui(lang, "calc.per"))}"><b>#{mg}</b><small>mg</small></span>)
  %(<a class="card" href="#{recipe_url(lang, r)}">#{cover(r["slug"], r["category_name"], r["glyph"], :card, dot)}<span class="nm">#{h(rname(r, lang))}</span></a>)
end

# Category photo (#57 variant B): the CAT_OG recipe's photo fades into the category colour on the band and the tiles.
# The photos are shot on that colour, so they blend; the colour block and the name inside it keep it unlike a recipe card.
def cat_photo(cat, kind)
  s = CAT_OG[cat]
  return nil unless PHOTOS[s]
  base = "/images/photos/#{s}"
  return %(<img src="#{base}-480.webp" width="480" height="360" alt="" loading="lazy" decoding="async">) if kind == :tile
  %(<img src="#{base}-800.webp" srcset="#{PHOTO_W.map { |x| "#{base}-#{x}.webp #{x}w" }.join(", ")}" sizes="(min-width:1000px) 520px, (min-width:720px) 400px, 62vw" width="1600" height="1200" alt="" fetchpriority="high">)
end

def cat_tile(lang, cat, with_count: true)
  inner = %(<b>#{h(category_t(lang, cat))}</b>) + (with_count ? %(<small>#{h(ui(lang, "shell.n_recipes", n: RECIPES_BY_CAT[cat].size))}</small>) : "")
  photo = cat_photo(cat, :tile)
  return %(<a href="#{cat_url(lang, cat)}"><span class="cv" style="#{cat_vars(cat)}">#{photo}#{inner}</span></a>) if photo
  %(<a href="#{cat_url(lang, cat)}">#{cover(cat, cat, CAT_GLYPH[cat], :tile, inner)}</a>)
end

# Search sheet tile: the name sits under the cover.
def cat_square(lang, cat); %(<a href="#{cat_url(lang, cat)}">#{cover(cat, cat, CAT_GLYPH[cat], :card)}#{h(category_t(lang, cat))}</a>); end

# skip_if: a JS condition under which the slot is never requested (the homepage in ?q= results mode has no ad).
def ad_slot(lang, unit, skip_if: nil)
  label = h(ui(lang, "ad.label"))
  push = "(adsbygoogle=window.adsbygoogle||[]).push({});"
  push = "if(!(#{skip_if}))#{push}" if skip_if
  %(<aside class="ad" aria-label="#{label}"><small>#{label}</small><ins class="adsbygoogle" style="display:block" data-ad-client="#{AD_CLIENT}" data-ad-slot="#{AD_UNITS.fetch(unit)}" data-ad-format="auto" data-full-width-responsive="true"></ins><script>#{push}</script></aside>)
end

# An article in this language, or the English one when it isn't translated (or is a frozen page).
def learn_href(lang, slug)
  a = ARTICLE_I18N.dig(lang, "articles", slug)
  lang == "en" || (a && !a["raw_main"]) ? "#{lang_prefix(lang)}/#{slug}.html" : "/#{slug}.html"
end

def learn_links(lang)
  names = ui(lang, "shell.learn_links")
  LEARN.each_with_index.map { |s, i| [learn_href(lang, s), names[i]] } + [["#{lang_prefix(lang)}/articles.html", names[4]]]
end

# ─────────────────────────────────────────────
# Shell: <head>, masthead + compact bar, footer + menu/search dialogs + scripts
# ─────────────────────────────────────────────

THEME_BOOT = %(<script>try{var t=localStorage.getItem("theme");document.documentElement.dataset.theme=t==="dark"||t==="light"?t:matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light"}catch(e){}</script>)

def shell_head(lang, title:, description:, page_path:, og_image:, og_h: 630, og_title: title, og_type: "website", structured: nil, keywords: nil, indexed: true, only_lang: false, langs: ALL_LANGS)
  canonical = "#{SITE}#{lang_prefix(lang)}/#{page_path}"
  ld = structured ? %(\n<script type="application/ld+json">#{structured}</script>) : ""
  kw = keywords ? %(\n<meta name="keywords" content="#{h(keywords)}">) : ""
  canon = indexed ? %(\n<link rel="canonical" href="#{canonical}">) : ""
  og_url = indexed ? %(\n<meta property="og:url" content="#{canonical}">) : ""
  tags = hreflang_tags(page_path, langs)
  alt = indexed && !tags.empty? ? "\n#{tags.gsub(" />", ">")}" : ""
  # a page that exists in one language only (about.html) points at itself, as before the redesign
  alt = %(\n<link rel="alternate" hreflang="#{lang_html(lang)}" href="#{canonical}">\n<link rel="alternate" hreflang="x-default" href="#{canonical}">) if only_lang
  ads = indexed ? %(\n<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=#{AD_CLIENT}" crossorigin="anonymous"></script>) : ""
  <<~HTML
    <!DOCTYPE html>
    <!-- Generated by scripts/build_site.rb from data/ and i18n/ — edit the source, not this file -->
    <html lang="#{lang_html(lang)}">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>#{h(title)}</title>
    <meta name="description" content="#{h(description)}">#{kw}#{canon}
    <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico">
    <meta property="og:type" content="#{og_type}">
    <meta property="og:site_name" content="HowToEdibles">
    <meta property="og:title" content="#{h(og_title)}">
    <meta property="og:description" content="#{h(description)}">
    <meta property="og:image" content="#{og_image}">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="#{og_h}">#{og_url}
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="#{h(og_title)}">
    <meta name="twitter:description" content="#{h(description)}">
    <meta name="twitter:image" content="#{og_image}">
    <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY">#{alt}
    <link rel="preload" href="/fonts/unbounded-800.latin1.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="stylesheet" href="/css/site.css">
    #{THEME_BOOT}#{ads}#{ld}
    </head>
  HTML
end

def logo_svg(cls = "logo", label: nil)
  aria = label ? %(role="img" aria-label="#{label}") : %(aria-hidden="true")
  %(<svg class="#{cls}" viewBox="#{LOGO_SYMBOL[/viewBox="([^"]+)"/, 1]}" width="240" height="#{LOGO_H}" #{aria}><use href="#logo"/></svg>)
end

# google-anno-skip: no ad intents (Google-inserted links in the text); Auto ads is off since 2026-11-11 (#75)
def shell_top(lang); %(<body class="google-anno-skip">\n#{SPRITE_HTML}\n) + masthead(lang); end

def masthead(lang)
  p = lang_prefix(lang)
  <<~HTML
    <div class="mini" id="mini"><div class="wrap"><a href="#{p}/" aria-label="HowToEdibles">#{logo_svg}</a><button type="button" class="spill" data-open="search">#{ICON[:search]}<span>#{h(ui(lang, "shell.search_short"))}</span></button><button type="button" class="ibtn" data-open="menu" aria-label="#{h(ui(lang, "shell.menu"))}" aria-haspopup="dialog">#{ICON[:menu]}</button></div></div>
    <div class="wrap">
    <header class="hdr"><a href="#{p}/">#{logo_svg(label: "HowToEdibles")}</a><div class="tools"><button type="button" class="ibtn" data-open="search" aria-label="#{h(ui(lang, "shell.search"))}" aria-haspopup="dialog">#{ICON[:search]}</button><button type="button" class="ibtn" data-open="menu" aria-label="#{h(ui(lang, "shell.menu"))}" aria-haspopup="dialog">#{ICON[:menu]}</button></div></header>
  HTML
end

def search_dialog(lang)
  p = lang_prefix(lang)
  ph = h(ui(lang, "shell.search_pill", n: RECIPES.size))
  rows = POPULAR.map { |s| RECIPES.find { |r| r["slug"] == s } }.map do |r|
    %(<li><a href="#{recipe_url(lang, r)}">#{cover(r["slug"], r["category_name"], r["glyph"], :thumb)}<div><b>#{h(rname(r, lang))}</b><span>#{h(category_t(lang, r["category_name"]))} · #{fmt_mg(default_mg(r), lang)} mg #{h(ui(lang, "calc.per"))}</span></div></a></li>)
  end.join
  none = { q: ui(lang, "search.none", q: "{q}"), all: ui(lang, "search.see_all", n: "{n}"), also: ui(lang, "search.also"), per: ui(lang, "calc.per") }
  <<~HTML
    <dialog id="search" aria-label="#{h(ui(lang, "shell.search"))}" data-index="/data/search-#{lang}.json" data-prefix="#{p}" data-t="#{h(JSON.generate(none))}"><div class="sheet-top"><div class="wrap"><form class="sbar" role="search" action="#{p}/">
    <label class="sfield">#{ICON[:search]}<input id="q" name="q" type="search" enterkeyhint="search" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="#{ph}" aria-label="#{ph}" aria-controls="sres"><button type="button" class="clear" id="qclear" aria-label="#{h(ui(lang, "search.clear"))}" hidden>#{ICON[:x]}</button></label>
    <button type="button" class="txtbtn" data-close>#{h(ui(lang, "search.cancel"))}</button></form></div></div>
    <div class="wrap" id="sres" aria-live="polite">
    <div id="s-idle"><p class="eyebrow">#{h(ui(lang, "shell.browse"))}</p><div class="cats">#{CAT_ORDER.map { |c| cat_square(lang, c) }.join}</div>
    <p class="eyebrow">#{h(ui(lang, "search.popular"))}</p><ul class="rows">#{rows}</ul>
    <a class="more" href="#{p}/calculator.html">#{ICON[:calc]}#{h(ui(lang, "shell.calc_card"))}</a></div>
    <div id="s-none" class="empty" hidden><h3></h3><p>#{h(ui(lang, "search.none_hint"))}</p><div class="cats">#{CAT_ORDER.first(4).map { |c| cat_square(lang, c) }.join}</div></div>
    <div id="s-list" hidden><ul class="rows" role="listbox" style="margin-top:6px"></ul><a class="more" hidden></a></div>
    </div></dialog>
  HTML
end

# The language switcher. page_path is one path for every language, or { lang => path } for pages
# that don't exist in every language (an untranslated article points to that language's articles index).
def lang_switch(lang, page_path)
  ALL_LANGS.map do |l|
    path = page_path.is_a?(Hash) ? page_path.fetch(l) : page_path
    %(<a href="#{lang_prefix(l)}/#{path}" lang="#{lang_html(l)}" hreflang="#{lang_html(l)}"#{l == lang ? ' aria-current="true"' : ""}>#{LANG_LABEL[l]}</a>)
  end.join
end

def menu_dialog(lang, page_path)
  p = lang_prefix(lang)
  langs = lang_switch(lang, page_path)
  modes = %w[auto light dark].each_with_index.map { |m, i| %(<button type="button" data-theme-set="#{m}" aria-pressed="#{m == "auto"}">#{h(ui(lang, "shell.modes")[i])}</button>) }.join
  <<~HTML
    <dialog id="menu" aria-label="#{h(ui(lang, "shell.menu"))}"><div class="sheet-top"><div class="wrap mtop"><a href="#{p}/" aria-label="HowToEdibles">#{logo_svg}</a>
    <div class="tools"><button type="button" class="ibtn" data-open="search" aria-label="#{h(ui(lang, "shell.search"))}">#{ICON[:search]}</button><button type="button" class="ibtn" data-close aria-label="#{h(ui(lang, "shell.close"))}">#{ICON[:x]}</button></div></div></div>
    <nav class="wrap" aria-label="#{h(ui(lang, "shell.menu"))}">
    <a class="calc-card" href="#{p}/calculator.html"><span class="ic">#{ICON[:calc]}</span><span><b>#{h(ui(lang, "shell.calc_card"))}</b><span>#{h(ui(lang, "shell.calc_card_sub"))}</span></span><span class="arr">#{ICON[:arr]}</span></a>
    <p class="eyebrow">#{h(ui(lang, "shell.recipes"))}</p><div class="tiles">#{CAT_ORDER.map { |c| cat_tile(lang, c) }.join}</div>
    <p class="eyebrow">#{h(ui(lang, "shell.learn"))}</p><ul class="links">#{learn_links(lang).map { |u, n| %(<li><a href="#{u}">#{h(n)}#{ICON[:arr]}</a></li>) }.join}</ul>
    <p class="eyebrow">#{h(ui(lang, "shell.language"))}</p><div class="seg">#{langs}</div>
    <p class="eyebrow">#{h(ui(lang, "shell.appearance"))}</p><div class="seg">#{modes}</div>
    <a class="helpbox" href="#{HELP_URL}" target="_blank" rel="noopener">#{ICON[:life]}#{h(ui(lang, "shell.help"))}</a>
    </nav></dialog>
  HTML
end

def shell_bottom(lang, page_path, scripts: ""); footer_dialogs(lang, page_path).chomp + scripts_tail(scripts); end

def scripts_tail(scripts = "")
  <<~HTML
    #{scripts}<script src="/js/shell.js" defer></script>
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-MGB628XR50"></script>
    <script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag("js",new Date());gtag("config","G-MGB628XR50");</script>
    </body>
    </html>
  HTML
end

def footer_dialogs(lang, page_path)
  p = lang_prefix(lang)
  more = ui(lang, "shell.more_links")
  more_links = [["#{p}/calculator.html", more[0]], ["/about.html", more[1]], ["/contact.html", more[2]], ["#{p}/donate.html", more[3]]]
  langs = lang_switch(lang, page_path)
  <<~HTML
    </div>
    <footer class="ftr"><div class="wrap">
    <nav class="cols" aria-label="#{h(ui(lang, "shell.recipes"))}"><div><h2>#{h(ui(lang, "shell.recipes"))}</h2>#{CAT_ORDER.map { |c| %(<a href="#{cat_url(lang, c)}">#{h(category_t(lang, c))}</a>) }.join}</div>
    <div><h2>#{h(ui(lang, "shell.learn"))}</h2>#{learn_links(lang).map { |u, n| %(<a href="#{u}">#{h(n)}</a>) }.join}<a href="#{HELP_URL}" target="_blank" rel="noopener">#{h(ui(lang, "shell.help"))}</a></div>
    <div><h2>#{h(ui(lang, "shell.more"))}</h2>#{more_links.map { |u, n| %(<a href="#{u}">#{h(n)}</a>) }.join}</div></nav>
    <div class="langs">#{langs}</div>
    <p>#{h(ui(lang, "shell.legal"))}</p>
    </div></footer>
    #{search_dialog(lang)}#{menu_dialog(lang, page_path)}
  HTML
end

# ─────────────────────────────────────────────
# Recipe page (#52 A · Stack, amended by #59)
# ─────────────────────────────────────────────

FAT_RE = /(cannabis-infused butter|canna-?butter|cannabisbutter|manteiga de cannabis|mantequilla de cannabis|大麻黄油)/i

# Only long words may hyphenate (13+ letters, 12+ in German, where "Gummibärchen" overflows a 344px phone);
# shorter ones move down whole, so "Cannabutter" is never split to fill the narrow line beside the sticker.
def title_html(name, lang)
  n = lang == "de" ? 12 : 13
  h(name).gsub(/\p{Latin}{#{n},}/) { %(<span class="hy">#{$&}</span>) }
end

# Title size band by visual length (CJK ≈ 1.7 Latin chars), so the line count holds on every phone width.
def title_class(name)
  n = name.each_char.sum { |c| c.match?(/[　-鿿]/) ? 1.7 : 1 }
  n > 24 ? "long" : n > 14 ? "mid" : nil
end

def duration(lang, m)
  return "–" if m.zero?
  m >= 60 ? "#{m / 60} #{ui(lang, "recipe.h")}#{m % 60 > 0 ? " #{m % 60}" : ""}" : "#{m} #{ui(lang, "recipe.min")}"
end

def iso_minutes(s)
  md = /PT(?:(\d+)H)?(?:(\d+)M)?/.match(s.to_s)
  md ? md[1].to_i * 60 + md[2].to_i : 0
end

# One ingredient/step line as a tap-to-strike checkbox. Inner HTML is our own data (links, the flower span).
def tick(html); %(<li><label><input type="checkbox"><span class="t">#{html}</span></label></li>); end

def ingredient_html(lang, slug, line, qty)
  line = line.gsub(%r{<span id="grams-quantity-recipe">[^<]*</span>}) { %(<span data-o="g">#{fmt_g(qty, lang)}</span>) }
  return line if slug == "cannabutter"
  first = ui(lang, "recipe.make_first")
  if (href = line[%r{<a [^>]*href="(/recipes/[^"/]+/)"}, 1])
    "#{line}<a class=\"make-first\" href=\"#{lang_prefix(lang)}#{href}\">#{h(first)}</a>"
  elsif line.match?(FAT_RE)
    # the button goes at the end, so a split line ("⅓ cup cannabutter + 3 tbsp butter") isn't cut in two
    line.sub(FAT_RE) { %(<a href="#{lang_prefix(lang)}/recipes/cannabutter/">#{$1}</a>) } +
      %(<a class="make-first" href="#{lang_prefix(lang)}/recipes/cannabutter/">#{h(first)}</a>)
  else
    line
  end
end

def recipe_lines(lang, recipe, qty)
  slug = recipe["slug"]
  ings = recipe_t(lang, slug, "ingredients")
  steps = recipe_t(lang, slug, "instructions")
  num = fmt_g(qty, lang)
  ings = if ings.is_a?(Array) && !ings.empty?
           ings.map { |ing| ing.sub(FLOWER_AMOUNT_RE) { %(<span data-o="g">#{num}</span>#{$2 || "&nbsp;g"}#{$3.empty? && !$2 ? " " : $3}#{$4}) } }
         else
           (recipe["ingredients"] || "").scan(%r{<li[^>]*>(.*?)</li>}m).map { |m| m[0].strip }
         end
  steps = steps.is_a?(Array) && !steps.empty? ? steps : (recipe["instructions"] || "").scan(%r{<li[^>]*>(.*?)</li>}m).map { |m| m[0].strip }
  [ings, steps]
end

# "More {category}": the next 4 recipes of the category, cyclically, so every recipe is linked from 4 others.
def related_for(recipe)
  list = RECIPES_BY_CAT[recipe["category_name"]]
  i = list.index(recipe)
  (1..[4, list.size - 1].min).map { |k| list[(i + k) % list.size] }
end

# The calculator card (#54 A · Steppers): ink result panel + 56px peek + grams › % THC › servings rows with preset chips.
# One card for the recipe page, the homepage hero and calculator.html; js/dose.js drives all three.
def calc_card(lang, g, s, n, n_chips, foot, top: "", potency_id: false)
  n_i = n.round
  mg = mg_of(g, s, n)
  presets = {
    "g" => [3.5, 7, 14, 28].each_with_index.map { |v, i| [v, "#{fmt_g(v, lang)} g", ui(lang, "calc.oz")[i]] },
    "s" => [[8, t(lang, "calculator", "potency_low")], [14, ui(lang, "calc.average")], [22, t(lang, "calculator", "potency_high")], [60, t(lang, "calculator", "potency_concentrates")]].map { |v, l| [v, "#{v}%", l] },
    "n" => n_chips,
  }
  cur = { "g" => g, "s" => s, "n" => n_i }
  qs = { "g" => t(lang, "calculator", "weed_quantity"), "s" => t(lang, "calculator", "weed_strength"), "n" => t(lang, "calculator", "portions_question") }
  units = { "g" => ui(lang, "calc.g"), "s" => "% #{ui(lang, "calc.thc")}", "n" => servings_word(lang, n_i) }
  vals = { "g" => fmt_g(g, lang), "s" => nf(s, 1, lang), "n" => n_i.to_s }
  rows = %w[g s n].map do |k|
    chips = presets[k].map { |v, a, b| %(<button type="button" class="chip" data-k="#{k}" data-v="#{v}" aria-pressed="#{cur[k] == v}">#{a}#{b ? "<small>#{h(b)}</small>" : ""}</button>) }.join
    %(<div class="row"#{potency_id && k == "s" ? ' id="potency"' : ""}><label class="q" for="in-#{k}">#{h(qs[k])}</label><div class="stepper"><button type="button" class="rnd" data-step="#{k}" data-d="-1" aria-label="−">#{ICON[:minus]}</button>) +
      %(<span class="fld"><input id="in-#{k}" data-in="#{k}" inputmode="decimal" enterkeyhint="done" autocomplete="off" value="#{vals[k]}"><span class="u" data-unit="#{k}">#{h(units[k])}</span></span>) +
      %(<button type="button" class="rnd" data-step="#{k}" data-d="1" aria-label="+">#{ICON[:plus]}</button></div><div class="chips" role="group" aria-label="#{h(qs[k])}">#{chips}</div></div>)
  end.join
  %(<div class="calc" id="calc">#{top}<div class="peek" aria-hidden="true" id="peek" style="--lc:#{LEVEL_COLORS[lvl_idx(mg)]}">#{peek_html(lang, g, s, n)}</div><div class="res" aria-live="polite" id="live">#{live_html(lang, g, s, n)}</div>\n) +
    %(<div class="ins">#{rows}</div>\n<div class="cfoot">#{foot}</div></div>)
end

def calc_links(lang, reset)
  p = lang_prefix(lang)
  %(<a href="#{p}/calculator.html">#{h(ui(lang, "calc.full"))}</a><a href="#{p}/calculator.html#potency">#{h(ui(lang, "calc.guide"))}</a><button type="button" class="reset" data-reset hidden>#{h(ui(lang, reset))}</button>)
end

def build_recipe_page(recipe, lang)
  p = lang_prefix(lang)
  slug = recipe["slug"]
  cat = recipe["category_name"]
  name = rname(recipe, lang)
  desc = recipe_t(lang, slug, "description") || recipe["description"]
  cat_t = category_t(lang, cat)
  page_path = "recipes/#{slug}/"
  canonical = "#{SITE}#{p}/#{page_path}"
  g = recipe["suggested_quantity"].to_f
  n = recipe["suggested_portion"].to_f
  s = DEFAULT_THC
  mg = mg_of(g, s, n)
  n_i = n.round
  enrich = ENRICHMENT[slug] || {}
  ings, steps = recipe_lines(lang, recipe, g)

  # ---- JSON-LD (content unchanged except: 1:1 schema raster, category page in the breadcrumb, publisher logo)
  plain = ->(x) { decode_entities(x.gsub(/<[^>]+>/, "")).strip }
  schema = {
    "@context" => "https://schema.org", "@type" => "Recipe", "name" => name, "description" => desc,
    "image" => schema_image(slug),
    "author" => ORG, "publisher" => PUBLISHER,
    "datePublished" => recipe["id"].to_i <= 140 ? "2024-06-01" : "2026-03-15", "dateModified" => "2026-03-15", # real_lastmods (build_site.rb) rewrites it to the sitemap lastmod
    "recipeCategory" => recipe_t(lang, slug, "category_name") || cat,
    "recipeYield" => [fmt_num(n), "#{fmt_num(n)} servings"],
    "recipeIngredient" => ings.map(&plain), # with the flower grams filled in, as on the page (the translations store a bare, stale number)
    "recipeInstructions" => steps.each_with_index.map { |x, i| { "@type" => "HowToStep", "position" => i + 1, "text" => (recipe_t(lang, slug, "instructions") ? x : plain.(x)) } },
    "url" => canonical,
  }
  %w[prepTime cookTime totalTime].each { |k| schema[k] = enrich[k] if enrich[k] }
  schema["keywords"] = enrich["keywords"].join(", ") if enrich["keywords"]
  if enrich["nutrition"]
    cal = enrich["nutrition"]["calories"].to_s
    schema["nutrition"] = { "@type" => "NutritionInformation", "calories" => cal.match?(/cal/i) ? cal : "#{cal} calories" }
    schema["nutrition"]["fatContent"] = enrich["nutrition"]["fatContent"] if enrich["nutrition"]["fatContent"]
  end
  crumbs = { "@context" => "https://schema.org", "@type" => "BreadcrumbList", "itemListElement" => [
    { "@type" => "ListItem", "position" => 1, "name" => "Home", "item" => "#{SITE}#{p}/" },
    { "@type" => "ListItem", "position" => 2, "name" => recipe_t(lang, slug, "category_name") || cat, "item" => "#{SITE}#{cat_url(lang, cat)}" },
    { "@type" => "ListItem", "position" => 3, "name" => name },
  ] }
  # No FAQPage here: the recipe FAQ is category template text (the same questions on up to 26 pages),
  # and Google only shows FAQ rich results for government and health sites. The visible FAQ stays.
  ld = [schema, crumbs]

  # ---- long-tail sections (template text + the recipe's own sentences)
  sub = enrich["sub_category"] || "general"
  tmpl = get_recipe_section_template(lang, cat, sub)
  # #92: the translated templates get the fat, temperature and category in their language (i18n/recipe_vars.json),
  # and the determiner before %{base_fat} agrees with the fat's gender (the templates assume pt/es masculine, de neuter).
  fat_en, temp_en = enrich["base_fat"] || "cannabutter", enrich["cook_temp"] || "350°F / 180°C"
  fat, gender = RECIPE_VARS.dig(lang, "base_fat", fat_en) || [fat_en]
  vars = { "name" => name, "base_fat" => fat, "cook_temp" => RECIPE_VARS.dig(lang, "cook_temp", temp_en) || temp_en, "category" => category_t(lang, cat) }
  agree = RECIPE_VARS.dig(lang, "agree", gender.to_s) || {}
  # ponytail: word swap on the 2 words before the slot ("no seu" → "na sua"), not grammar; a German nominative after a masculine fat stays accusative
  ip = ->(x, v = vars) { interpolate(x.is_a?(String) ? x.gsub(/(?:\S+ )?\S+(?= %\{base_fat\})/) { |w| w.split(" ").map { |y| agree[y] || y }.join(" ") } : x, v) }
  own = ->(k) { x = recipe_t(lang, slug, k) || enrich[k]; x && !x.empty? ? [x] : [] }
  list = ->(k, u = nil) { (tmpl[k] || []).map { |x| ip.(x) } + (u ? own.(u) : []) }
  label = ->(k) { ip.(get_section_label(lang, k)) }
  # German capitalises nouns, so its recipe name keeps its case in the intro sentence
  intro = "#{ip.(tmpl["intro"] || "", vars.merge("name" => lang == "de" ? name : name.downcase))} #{own.("intro_unique").first}".strip
  tips = list.("dosing_tips", "dosing_unique")
  accs = [["common_mistakes", list.("common_mistakes")], ["storage", list.("storage", "storage_unique")], ["variations", list.("variations", "variation_unique")]].reject { |_, l| l.empty? }
  # a template question with "only" fits just those recipes of the template (#108)
  faqs = (tmpl["faq"] || []).select { |f| !f["only"] || f["only"].include?(slug) }.map { |f| [ip.(f["q"]), ip.(f["a"])] }
  ul = ->(l) { %(<ul class="tips">#{l.map { |x| "<li>#{x}</li>" }.join}</ul>) }
  pm = %(<span class="pm">#{ICON[:plus]}</span>)

  total = iso_minutes(enrich["totalTime"]).nonzero? || iso_minutes(enrich["prepTime"]) + iso_minutes(enrich["cookTime"])
  tc = title_class(name)
  adj_sub = ui(lang, "recipe.adjust_sub", g: fmt_g(g, lang), p: nf(s, 1, lang))
  wake = ->(cls = "") { %(<button type="button" class="wake #{cls}" data-wake aria-pressed="false"><span class="dot">#{ICON[:sun]}</span><span>#{h(ui(lang, "recipe.wake"))}</span></button>) }
  summary = interpolate(t(lang, "calculator", "dose_summary"), "grams" => nf(g, 2, lang), "potency" => nf(s, 1, lang), "servings" => nf(n, 0, lang), "mg" => nf(mg, 1, lang))


  main = <<~HTML
    <main class="page">
    <section class="hero#{tc ? " #{tc}" : ""}" style="#{cat_vars(cat)}">#{cover(slug, cat, recipe["glyph"], :hero, alt: name)}<a class="crumb" href="#{cat_url(lang, cat)}">#{h(cat_t)}</a>
    <a class="sticker" href="#dose" id="sticker"><b data-o="mgs">#{fmt_mg(mg, lang)}<small>mg</small></b><span>#{h(ui(lang, "calc.per"))}</span></a>
    <span class="sticker-room" aria-hidden="true"></span><h1>#{title_html(name, lang)}</h1>
    <div class="facts"><div><b>#{duration(lang, total)}</b><span>#{h(ui(lang, "recipe.total"))}</span></div><div><b data-o="n">#{n_i}</b><span>#{h(ui(lang, "recipe.makes"))}</span></div><div><b data-o="batch">#{fmt_mg(mg * n, lang)} mg</b><span>#{h(ui(lang, "calc.batch"))}</span></div></div>
    <p class="newbie">#{ICON[:warn]}<span data-o="newbie">#{newbie_html(lang, mg)}</span></p>
    <div class="cta"><a class="btn" href="#dose">#{ICON[:dial]}<span>#{h(ui(lang, "recipe.adjust"))}<small data-o="adj">#{h(adj_sub)}</small></span></a><a class="btn pri" href="#recipe">#{h(ui(lang, "recipe.jump"))}#{ICON[:down]}</a></div></section>
    <div class="intro"><p>#{h(desc)}</p>#{intro.empty? ? "" : "<p>#{intro}</p>"}</div>
    <div class="rail"><section class="block" id="dose"><h2>#{h(ui(lang, "calc.your_dose"))}</h2><p class="hint">#{h(summary)}</p>
    #{calc_card(lang, g, s, n, [[n_i, n_i.to_s, ui(lang, "calc.this_recipe")]] + [12, 24, 50].reject { |v| v == n_i }.map { |v| [v, v.to_s, nil] }, calc_links(lang, "calc.reset_recipe"))}
    <a class="help" href="#{HELP_URL}" target="_blank" rel="noopener">#{ICON[:life]}#{h(ui(lang, "shell.help"))}</a></section></div>
    <section class="block" id="recipe"><div class="bh"><h2>#{h(t(lang, "recipe_page", "ingredients"))}</h2>#{wake.()}</div><p class="hint">#{h(ui(lang, "recipe.tap"))}</p><ul class="ticks">#{ings.map { |x| tick(ingredient_html(lang, slug, x, g)) }.join}</ul></section>
    <section class="block"><div class="bh"><h2>#{h(t(lang, "recipe_page", "directions"))}</h2></div><ol class="ticks steps" style="#{cat_vars(cat)}">#{steps.map { |x| tick(x) }.join}</ol>#{wake.("wake-big")}<p class="wake-note" data-wake-note hidden>#{h(ui(lang, "recipe.wake_no"))}</p></section>
    #{ad_slot(lang, "recipe-mid")}
    #{tips.empty? ? "" : %(<section class="block"><h2>#{h(label.("dosing_tips"))}</h2>#{ul.(tips)}#{accs.empty? ? "" : %(<div class="accs">#{accs.map { |k, l| %(<details class="acc"><summary><h2>#{h(label.(k))}</h2>#{pm}</summary><div class="body">#{ul.(l)}</div></details>) }.join}</div>)}</section>)}
    #{faqs.empty? ? "" : %(<section class="block"><h2>#{h(label.("faq"))}</h2><div class="accs">#{faqs.map { |q, a| %(<details class="acc"><summary><h3>#{h(q)}</h3>#{pm}</summary><div class="body"><p>#{h(a)}</p></div></details>) }.join}</div></section>)}
    #{ad_slot(lang, "recipe-end")}
    <section class="block"><h2>#{h(ui(lang, "recipe.related", c: cat_t))}</h2><div class="grid">#{related_for(recipe).map { |r| card(r, lang) }.join}</div></section>
    </main>
  HTML

  dose = { d: { g: g, s: s, n: n_i }, lang: lang, t: dose_strings(lang) }
  scripts = %(<script>window.DOSE=#{JSON.generate(dose)};</script>\n<script src="/js/dose.js" defer></script>\n)
  # Optional English SERP copy per recipe (#86, a CTR test): seo_title / seo_description in recipes.json, with
  # {mg} {n} {g} from the recipe defaults. The H1, the JSON-LD and the other languages keep the recipe's own copy.
  seo = ->(k) { (x = lang == "en" && recipe["seo_#{k}"]) && x.gsub("{mg}", fmt_mg(mg, lang)).gsub("{n}", n_i.to_s).gsub("{g}", fmt_g(g, lang)) }
  page = shell_head(lang, title: seo.("title") ? "#{seo.("title")} | HowToEdibles" : "#{name} #{t(lang, "recipe_page", "title_suffix")}", description: seo.("description") || desc, page_path: page_path,
                    og_image: "#{SITE}/#{recipe_og(lang, slug)}", og_type: "article", structured: JSON.generate(ld))
  page << shell_top(lang) << main << shell_bottom(lang, page_path, scripts: scripts)
  write_file(output_path(lang, "recipes", slug, "index.html"), page)
  raster_jobs(recipe, lang, name, mg)
end

# ─────────────────────────────────────────────
# Category page (#53, #73)
# ─────────────────────────────────────────────

def build_category_page(cat, lang)
  p = lang_prefix(lang)
  list = RECIPES_BY_CAT[cat]
  cat_t = category_t(lang, cat)
  slug = CAT_BY_NAME[cat]["slug"]
  page_path = "category/#{slug}/"
  lede = ui(lang, "home.cat_lede", n: list.size)
  cells = list.map { |r| card(r, lang) }
  cells.insert([8, cells.size].min, ad_slot(lang, "category").sub('class="ad"', 'class="ad span"'))
  band_calc = %(<a class="band-calc span" href="#{p}/calculator.html"><span><b>#{h(ui(lang, "home.band_calc"))}</b><span>#{h(ui(lang, "home.band_calc_sub"))}</span></span><span class="go">#{ICON[:arr]}</span></a>)
  cells.insert(23, band_calc) if cells.size > 23
  chips = %(<a href="#{p}/">#{h(ui(lang, "shell.all_recipes"))} <small>#{RECIPES.size}</small></a>) +
          CAT_ORDER.map { |c| %(<a href="#{cat_url(lang, c)}" style="#{cat_vars(c)}"#{c == cat ? ' aria-current="page"' : ""}><i></i>#{h(category_t(lang, c))} <small>#{RECIPES_BY_CAT[c].size}</small></a>) }.join
  support = ui(lang, "home.support").sub('href="#"', %(href="#{p}/donate.html"))
  photo = cat_photo(cat, :band)
  main = <<~HTML
    <main>
    <section class="band#{photo ? " ph" : ""}" style="#{cat_vars(cat)}">#{photo || glyph_svg(CAT_GLYPH[cat])}<a class="back" href="#{p}/">← #{h(ui(lang, "shell.all_recipes"))}</a><h1>#{h(cat_t)}</h1><p>#{h(lede)}</p></section>
    <nav class="chips nav" aria-label="#{h(ui(lang, "shell.browse"))}">#{chips}</nav>
    <div class="grid">#{cells.join}</div>
    <div class="sh"><h2>#{h(ui(lang, "home.learn"))}</h2></div><ul class="learn">#{learn_links(lang).map { |u, n| %(<li><a href="#{u}">#{h(n)}</a></li>) }.join}</ul>
    <p class="hint" style="margin-top:28px">#{support}</p>
    </main>
  HTML
  ld = [
    { "@context" => "https://schema.org", "@type" => "CollectionPage", "name" => cat_t, "description" => lede, "url" => "#{SITE}#{p}/#{page_path}",
      "mainEntity" => { "@type" => "ItemList", "numberOfItems" => list.size,
                        "itemListElement" => list.each_with_index.map { |r, i| { "@type" => "ListItem", "position" => i + 1, "url" => "#{SITE}#{recipe_url(lang, r)}", "name" => rname(r, lang) } } } },
    { "@context" => "https://schema.org", "@type" => "BreadcrumbList", "itemListElement" => [
      { "@type" => "ListItem", "position" => 1, "name" => "Home", "item" => "#{SITE}#{p}/" },
      { "@type" => "ListItem", "position" => 2, "name" => cat_t } ] },
  ]
  desc = "#{lede} #{list.first(4).map { |r| rname(r, lang) }.join(", ")}…"
  og = PHOTOS[CAT_OG[cat]] ? ["#{SITE}/images/photos/#{CAT_OG[cat]}-16x9.jpg", 675] : [SITE_OG, 630]
  page = shell_head(lang, title: "#{cat_t} · #{ui(lang, "shell.n_recipes", n: list.size)} | HowToEdibles", description: desc,
                    page_path: page_path, og_image: og[0], og_h: og[1], structured: JSON.generate(ld))
  page << shell_top(lang) << main << shell_bottom(lang, page_path)
  write_file(output_path(lang, "category", slug, "index.html"), page)
end

# ─────────────────────────────────────────────
# Special pages (#74): homepage, calculator.html, donate, articles index, the root 404
# ─────────────────────────────────────────────

CALC_DEFAULT = [3.5, DEFAULT_THC, 50].freeze # calculator.html and the homepage card
CALC_N_CHIPS = [12, 24, 50, 100].map { |v| [v, v.to_s, nil] }.freeze
CALC_UPDATED = { "en" => "March 2026", "pt" => "março de 2026", "es" => "marzo de 2026", "de" => "März 2026", "zh" => "2026年3月" }.freeze
# The organization is defined once, on the homepage (#107); every other page points at it by @id.
ORG = { "@type" => "Organization", "@id" => "#{SITE}/#org", "name" => "HowToEdibles", "url" => SITE }.freeze
PUBLISHER = ORG.merge("logo" => { "@type" => "ImageObject", "url" => "#{SITE}/images/brand/logo.png" }).freeze
ORG_SAME_AS = %w[https://instagram.com/howtoedibles https://facebook.com/howtoedibles].freeze # the profiles about.html lists
SITE_OG = "#{SITE}/images/brand/og-image.jpg"

# A string only this language has (no English fallback): the English pages keep keywords and schema copy the others never had.
def own(lang, *keys); I18N[lang].dig(*keys); end

# Poster band (#60): the header of every non-recipe page, a colour block with an oversized cropped typographic mark.
def poster(cat, mark, inner, cls: nil, mk: "")
  %(<header class="poster#{cls ? " #{cls}" : ""}" style="#{cat_vars(cat)};#{mk}"><span class="mk" aria-hidden="true">#{h(mark)}</span>#{inner}</header>)
end

def search_form(lang, value = "")
  ph = h(ui(lang, "shell.search_pill", n: RECIPES.size))
  %(<form class="sbox" role="search" action="#{lang_prefix(lang)}/"><input name="q" type="search" enterkeyhint="search" autocomplete="off" value="#{h(value)}" placeholder="#{ph}" aria-label="#{ph}" data-open="search"><button type="submit">#{h(ui(lang, "shell.search"))}</button></form>)
end

def learn_block(lang)
  support = ui(lang, "home.support").sub('href="#"', %(href="#{lang_prefix(lang)}/donate.html"))
  %(<div class="sh"><h2>#{h(ui(lang, "home.learn"))}</h2></div><ul class="learn">#{learn_links(lang).map { |u, n| %(<li><a href="#{u}">#{h(n)}</a></li>) }.join}</ul>\n<p class="hint" style="margin-top:28px">#{support}</p>)
end

def dose_script(lang, g, s, n)
  dose = { d: { g: g, s: s, n: n }, lang: lang, t: dose_strings(lang).merge(you: ui(lang, "calcpage.you")) }
  %(<script>window.DOSE=#{JSON.generate(dose)};</script>\n<script src="/js/dose.js" defer></script>\n)
end

def write_page(lang, file, head, main, page_path, scripts: "")
  write_file(output_path(lang, file), head + shell_top(lang) + main + shell_bottom(lang, page_path, scripts: scripts))
end

# ---- homepage (#53: C · Dose desk top, then A · Shelves) ----

def shelf(lang, cat, title, sub = nil)
  list = RECIPES_BY_CAT[cat]
  url = cat_url(lang, cat)
  head = %(<div class="sh"><h2><i></i><span>#{title}#{sub ? %(<small>#{h(sub)}</small>) : ""}</span></h2><a href="#{url}">#{h(ui(lang, "home.all_n", n: list.size))}</a></div>)
  all = %(<a class="all" href="#{url}"><b>#{list.size}</b>#{h(category_t(lang, cat))}<span>#{h(ui(lang, "home.see_all"))} →</span></a>)
  %(<section class="shelf" style="#{cat_vars(cat)}">#{head}<div class="strip">#{list.first(8).map { |r| card(r, lang) }.join}#{all}</div></section>)
end

def build_home(lang)
  p = lang_prefix(lang)
  g, s, n = CALC_DEFAULT
  title = t(lang, "homepage", "hero_title")
  i = title.rindex(" & ")
  h1 = i ? "#{h(title[0, i + 3])}<mark>#{h(title[i + 3..])}</mark>" : h(title)
  top = %(<p class="cq">#{h(ui(lang, "home.hero_q"))}</p>)
  calc = calc_card(lang, g, s, n, CALC_N_CHIPS, calc_links(lang, "calc.reset"), top: top)
  shelves = (["Essentials"] + (CAT_ORDER - ["Essentials"])).each_with_index.map do |c, k|
    sh = k.zero? ? shelf(lang, c, h(ui(lang, "home.base")), ui(lang, "home.base_sub")) : shelf(lang, c, h(category_t(lang, c)))
    k == 1 ? sh + ad_slot(lang, "home", skip_if: QMODE) : sh
  end.join("\n")
  rt = { title: ui(lang, "home.q_title", q: "{q}"), n: ui(lang, "home.q_n", n: "{n}"), none: ui(lang, "home.q_none", q: "{q}") }
  main = <<~HTML
    <main class="home">
    <script>if(/[?&](q|search)=[^&]/.test(location.search))document.documentElement.classList.add("q")</script>
    <div id="home">
    <section class="hh"><h1>#{h1}</h1><div class="rail hcalc" id="dose">#{calc}</div><p class="or">#{h(ui(lang, "home.or"))}</p>#{search_form(lang)}</section>
    <section><div class="sh"><h2>#{h(ui(lang, "shell.browse"))}</h2></div><div class="tiles">#{CAT_ORDER.map { |c| cat_tile(lang, c) }.join}</div></section>
    #{shelves}
    </div>
    <section id="results" data-t="#{h(JSON.generate(rt))}"><div class="qh"><h2></h2><p id="qn"></p>#{search_form(lang)}</div><div class="grid" id="qgrid"></div>
    <div id="qnone" hidden><p></p><div class="tiles">#{CAT_ORDER.first(4).map { |c| cat_tile(lang, c) }.join}</div></div></section>
    #{learn_block(lang)}
    </main>
  HTML
  ld = [{ "@context" => "https://schema.org", "@type" => "WebSite", "name" => "HowToEdibles", "url" => lang == "en" ? SITE : "#{SITE}#{p}/",
          "description" => own(lang, "homepage", "schema_description") || t(lang, "homepage", "description"), "publisher" => { "@id" => ORG["@id"] },
          "potentialAction" => { "@type" => "SearchAction", "target" => { "@type" => "EntryPoint", "urlTemplate" => "#{SITE}#{p}/?q={search_term_string}" }, "query-input" => "required name=search_term_string" } },
        { "@context" => "https://schema.org", **PUBLISHER, "foundingDate" => "2017", "sameAs" => ORG_SAME_AS }]
  head = shell_head(lang, title: t(lang, "homepage", "title"), description: t(lang, "homepage", "description"), page_path: "", og_image: SITE_OG,
                    structured: JSON.generate(ld), keywords: own(lang, "homepage", "keywords"))
  write_page(lang, "index.html", head, main, "", scripts: dose_script(lang, g, s, n))
end
QMODE = %(document.documentElement.classList.contains("q"))

# ---- calculator.html (#54 card + #60 poster page) ----

def eq_html(lang, g, s, n)
  "10 × #{fmt_g(g, lang)} × #{nf(s, 1, lang)} × #{nf(COOKING_EFFICIENCY, 1, lang)} ÷ #{n} = <b>#{fmt_mg(mg_of(g, s, n), lang)} mg</b>"
end

def build_calc_page(lang)
  p = lang_prefix(lang)
  c = ->(k) { t(lang, "calculator", k) }
  g, s, n = CALC_DEFAULT
  cur = lvl_idx(mg_of(g, s, n))
  canonical = "#{SITE}#{p}/calculator.html"
  you = %(<span class="you">#{h(ui(lang, "calcpage.you"))}</span>)
  e = nf(COOKING_EFFICIENCY, 1, lang)
  band = poster("Desserts", "mg", %(<span class="tag">#{h(ui(lang, "calcpage.eyebrow"))}</span><h1>#{h(c["calc_page_title"])}</h1><p class="meta"><time datetime="2026-03-04">#{h(ui(lang, "calcpage.updated", date: CALC_UPDATED[lang]))}</time></p>),
                cls: "over", mk: "--ms:210px;--my:18px;--mx:-.06em")
  foot = %(<a href="#guide">#{h(c["dosage_guide_title"])}</a><button type="button" class="reset" data-reset hidden>#{h(ui(lang, "calc.reset"))}</button>)
  rail = %(<div class="rail"><section class="block" id="dose" aria-label="#{h(ui(lang, "calc.your_dose"))}">#{calc_card(lang, g, s, n, CALC_N_CHIPS, foot, potency_id: true)}) +
         %(<p class="newbie">#{ICON[:warn]}<span>#{h(ui(lang, "calc.beginner"))} <a href="#{beginner_href(lang)}">#{h(ui(lang, "calc.beginner_link"))}</a></span></p>) +
         %(<a class="help" href="#{HELP_URL}" target="_blank" rel="noopener">#{ICON[:life]}#{h(ui(lang, "shell.help"))}</a></section></div>)
  rows = LEVELS.each_with_index.map do |l, i|
    %(<tr data-lvl="#{i}" style="--c:#{LEVEL_COLORS[i]}"#{i == cur ? ' aria-current="true"' : ""}><td>#{h(c["dosage_#{l[0]}"])}#{i == cur ? you : ""}</td><td>#{RANGES[i]}</td><td>#{h(c["dosage_#{l[0]}_desc"])}</td></tr>)
  end.join
  legend = [["G", "fx_g"], ["S", "fx_s"], [e, "fx_e"], ["N", "fx_n"], ["P", "fx_p"]].map { |k, v| "<dt>#{k}</dt><dd>#{h(ui(lang, "calcpage.#{v}"))}</dd>" }.join
  faqs = (1..6).map { |i| [t(lang, "faq", "q#{i}"), t(lang, "faq", "a#{i}")] }
  pm = %(<span class="pm">#{ICON[:plus]}</span>)
  main = <<~HTML
    <main>
    #{band}
    <div class="page">
    #{rail}
    <p class="lede">#{c["calc_page_intro"]}</p>
    <section class="block" id="guide"><h2>#{h(c["dosage_guide_title"])}</h2><p class="hint">#{h(ui(lang, "calcpage.guide_sub"))}</p>
    <table class="dt"><thead><tr><th>#{h(c["dosage_level"])}</th><th>#{h(c["dosage_per_serving"])}</th><th>#{h(c["dosage_effects"])}</th></tr></thead><tbody>#{rows}</tbody></table></section>
    <section class="block" id="formula"><h2>#{h(ui(lang, "calcpage.fx_title"))}</h2><p class="hint">#{h(ui(lang, "calcpage.fx_sub"))}</p>
    <div class="fx"><p class="eq" aria-label="P = 10 × G × S × #{e} ÷ N"><span>P</span><span>=</span><span>10</span><span>×</span><i>G</i><span>×</span><i>S</i><span>×</span><i>#{e}</i><span>÷</span><i>N</i></p><dl>#{legend}</dl></div>
    <div class="ex"><small>#{h(ui(lang, "calcpage.ex_title"))} · #{h(ui(lang, "calcpage.ex"))}</small><p>#{eq_html(lang, 3.5, 20, 20)}</p></div>
    <div class="ex live"><small>#{h(ui(lang, "calcpage.ex_yours"))}</small><p data-o="eq">#{eq_html(lang, g, s, n)}</p></div>
    <p class="hint"><a href="#{learn_href(lang, "how-a-cannabis-calculator-works")}">#{h(c["how_math_works"])}</a></p></section>
    #{ad_slot(lang, "calc-mid")}
    <section class="block"><h2>#{h(c["how_to_use_title"])}</h2><ol class="howto">#{(1..4).map { |i| "<li><span>#{c["how_to_step_#{i}"]}</span></li>" }.join}</ol></section>
    <section class="block"><div class="bh"><h2>#{h(c["try_recipe_title"])}</h2><a href="#{p}/">#{h(c["all_recipes"])}</a></div><p class="hint">#{h(c["try_recipe_sub"])}</p>
    <div class="grid">#{%w[cannabutter infused-coconut-oil gummy-bears pot-cookies pot-brownies infused-lemonade].map { |sl| card(RECIPES.find { |r| r["slug"] == sl }, lang) }.join}</div></section>
    <section class="block"><h2>#{h(c["faq_title"])}</h2><div class="accs">#{faqs.map { |q, a| %(<details class="acc"><summary><h3>#{h(q)}</h3>#{pm}</summary><div class="body"><p>#{h(a)}</p></div></details>) }.join}</div></section>
    #{ad_slot(lang, "calc-end")}
    <aside class="box">#{ICON[:warn]}<p>#{h(c["safety_note"])}</p></aside>
    </div>
    </main>
  HTML
  desc = c["page_description"]
  ld = [
    { "@context" => "https://schema.org", "@type" => "WebApplication", "name" => c["calc_page_title"], "url" => canonical, "description" => desc,
      "applicationCategory" => "HealthApplication", "operatingSystem" => "Any", "browserRequirements" => "Requires JavaScript",
      "datePublished" => "2017-03-01", "dateModified" => "2026-03-04", "offers" => { "@type" => "Offer", "price" => "0", "priceCurrency" => "USD" }, "creator" => ORG, "author" => ORG },
    { "@context" => "https://schema.org", "@type" => "FAQPage", "mainEntity" => faqs.map { |q, a| { "@type" => "Question", "name" => q, "acceptedAnswer" => { "@type" => "Answer", "text" => a } } } },
  ]
  if (headline = own(lang, "calculator", "headline"))
    ld << { "@context" => "https://schema.org", "@type" => "Article", "headline" => headline, "url" => canonical, "datePublished" => "2017-03-01", "dateModified" => "2026-03-04",
            "author" => ORG, "publisher" => PUBLISHER, "image" => SITE_OG, "description" => desc }
  end
  head = shell_head(lang, title: c["page_title"], description: desc, page_path: "calculator.html", og_image: SITE_OG, structured: JSON.generate(ld), keywords: own(lang, "calculator", "keywords"))
  write_page(lang, lang == "en" ? "edible-dosage-calculator/index.html" : "calculator.html", head, main, "calculator.html", scripts: dose_script(lang, g, s, n))
  return unless lang == "en"
  # the old English URL becomes the redirect (written directly: write_file would rewrite its target)
  File.write(File.join(ROOT_DIR, "calculator.html"), <<~HTML)
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta http-equiv="refresh" content="0;url=#{EN_CALC}" />
      <link rel="canonical" href="#{SITE}#{EN_CALC}" />
      <title>Redirecting…</title>
    </head>
    <body>
      <p>Redirecting to <a href="#{EN_CALC}">the calculator</a>…</p>
    </body>
    </html>
  HTML
end

# ---- articles index (#60: "Start here" cards, then per topic a lead card + slim rows) ----

# The index's topics, keyed by the English category; Dosing and Harm Reduction sit under Guides, as on the old index.
TOPIC_ORDER = %w[Edibles Health Guides Wellness Science Topicals Culture Legalization Industry].freeze
TOPIC_COLOR = { "Edibles" => "Desserts", "Health" => "Vegan", "Wellness" => "Keto", "Topicals" => "Snacks", "Culture" => "Lunch",
                "Legalization" => "International", "Industry" => "International", "Guides" => "Essentials", "Science" => "Drinks" }.freeze
START_HERE = %w[cannabis-edibles-for-beginners how-long-do-edibles-take-to-kick-in how-a-cannabis-calculator-works how-to-prevent-a-bad-trip].freeze

def topic_of(slug)
  c = ARTICLE_I18N.dig("en", "articles", slug, "category")
  TOPIC_COLOR.key?(c) ? c : "Guides"
end

# The articles that exist in this language (50 in en, 28 elsewhere; frozen raw_main pages are left out), in index order.
def articles_in(lang)
  arts = ARTICLE_I18N.dig(lang, "articles") || {}
  order = ARTICLE_I18N.dig(lang, "articles_index", "article_order") || arts.keys
  order.filter_map { |s| a = arts[s]; [s, a] if a && !a["raw_main"] }
end

def fold(s); s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase; end

def build_articles_index(lang)
  p = lang_prefix(lang)
  ai = ARTICLE_I18N.dig(lang, "articles_index")
  list = articles_in(lang)
  name = ->(a) { a["short_title"] || a["title"] }
  href = ->(s) { "#{p}/#{s}.html" }
  by = TOPIC_ORDER.to_h { |k| [k, list.select { |s, _| topic_of(s) == k }] }.reject { |_, v| v.empty? }
  label = ->(k) { ai.dig("categories", k) || (lang == "en" ? k : by[k].first[1]["category"]) }
  li = ->(s, a, inner) { %(<li data-t="#{topic_of(s)}" data-s="#{h(fold("#{name.(a)} #{a["description"]}"))}">#{inner}</li>) }
  slim = ->((s, a)) { li.(s, a, %(<a href="#{href.(s)}"><b>#{h(name.(a))}</b>#{ICON[:arr]}</a>)) }
  secs = by.map do |k, arts|
    (s0, a0), *rest = arts
    lead = li.(s0, a0, %(<a class="lead tone" style="#{cat_vars(TOPIC_COLOR[k])}" href="#{href.(s0)}"><span class="n" aria-hidden="true">#{h(name.(a0).strip[0])}</span><b>#{h(name.(a0))}</b><span>#{h(a0["description"])}</span></a>))
    more = rest.drop(3)
    %(<section class="tsec" style="#{cat_vars(TOPIC_COLOR[k])}"><h2><i></i>#{h(label.(k))}<em>#{arts.size}</em></h2><ul class="leadl">#{lead}</ul>) +
      (rest.empty? ? "" : %(<ul class="alist">#{rest.first(3).map(&slim).join}</ul>)) +
      (more.empty? ? "" : %(<details class="morel"><summary>#{h(ui(lang, "articles.see_all", n: arts.size))}<span class="pm">#{ICON[:plus]}</span></summary><ul class="alist">#{more.map(&slim).join}</ul></details>)) +
      "</section>"
  end.join("\n")
  start = START_HERE.filter_map { |s| list.find { |x, _| x == s } }.each_with_index.map do |(s, a), i|
    %(<a class="tone" style="#{cat_vars(TOPIC_COLOR[topic_of(s)])}" href="#{href.(s)}"><span class="n" aria-hidden="true">#{i + 1}</span><b>#{h(name.(a))}</b><small>#{h(label.(topic_of(s)))}</small></a>)
  end.join
  chips = %(<button type="button" class="chip" data-topic="" aria-pressed="true">#{h(ui(lang, "articles.all"))}<em>#{list.size}</em></button>) +
          by.map { |k, arts| %(<button type="button" class="chip tone" style="#{cat_vars(TOPIC_COLOR[k])}" data-topic="#{k}" aria-pressed="false"><i></i>#{h(label.(k))}<em>#{arts.size}</em></button>) }.join
  search = h(ui(lang, "articles.search"))
  main = <<~HTML
    <main>
    #{poster("Desserts", nf(list.size, 0, lang), %(<span class="tag">#{h(ui(lang, "shell.learn"))}</span><h1>#{h(ui(lang, "articles.h1"))}</h1><p class="deck">#{h(ui(lang, "articles.deck"))}</p>), mk: "--ms:300px;--my:-.3em;--mx:-.02em;--mr:-6deg")}
    <label class="asearch">#{ICON[:search]}<input type="search" id="aq" placeholder="#{search}" aria-label="#{search}" autocomplete="off" enterkeyhint="search"></label>
    <div class="topics" role="group" aria-label="#{h(ui(lang, "shell.browse"))}">#{chips}</div>
    <p class="count" id="acount" data-t="#{h(ui(lang, "articles.n", n: "{n}"))}">#{h(ui(lang, "articles.n", n: list.size))}</p>
    #{start.empty? ? "" : %(<section class="block" id="start"><h2>#{h(ui(lang, "articles.start"))}</h2><div class="start">#{start}</div></section>)}
    <div class="tsecs" id="alist">
    #{secs}
    </div>
    <p class="none" id="anone" hidden>#{h(ui(lang, "articles.none"))}</p>
    </main>
  HTML
  canonical = "#{SITE}#{p}/articles.html"
  ld = [
    { "@context" => "https://schema.org", "@type" => "BreadcrumbList", "itemListElement" => [
      { "@type" => "ListItem", "position" => 1, "name" => ai["breadcrumb_home"], "item" => "#{SITE}#{p}/" },
      { "@type" => "ListItem", "position" => 2, "name" => ai["breadcrumb_articles"], "item" => canonical } ] },
    { "@context" => "https://schema.org", "@type" => "ItemList", "name" => ai["hero_title"], "description" => ai["list_description"] || ai["page_description"], "numberOfItems" => list.size,
      "itemListElement" => list.each_with_index.map { |(s, a), i| { "@type" => "ListItem", "position" => i + 1, "name" => name.(a), "url" => "#{SITE}#{href.(s)}" } } },
  ]
  head = shell_head(lang, title: ai["page_title"], description: ai["page_description"], page_path: "articles.html", og_image: SITE_OG, structured: JSON.generate(ld), keywords: ai["keywords"])
  write_page(lang, "articles.html", head, main, "articles.html", scripts: %(<script>#{ARTICLES_JS}</script>\n))
end

# Search and topic chips filter the static lists; any filter opens every "See all" and hides "Start here".
ARTICLES_JS = <<~JS.gsub(/\n\s*/, "")
  (function(){var d=document,q=d.getElementById("aq"),n=d.getElementById("acount"),st=d.getElementById("start"),tp="";
  function f(s){return s.normalize("NFD").replace(/[\\u0300-\\u036f]/g,"").toLowerCase()}
  function run(){var v=f(q.value.trim()),k=0;d.querySelectorAll("#alist li").forEach(function(li){var on=(!tp||li.dataset.t===tp)&&(!v||li.dataset.s.indexOf(v)>=0);li.hidden=!on;k+=on});
  d.querySelectorAll("#alist .tsec").forEach(function(s){s.hidden=!s.querySelector("li:not([hidden])")});
  d.querySelectorAll("#alist .morel").forEach(function(m){m.open=!!(v||tp);m.hidden=!m.querySelector("li:not([hidden])")});
  if(st)st.hidden=!!(v||tp);n.textContent=n.dataset.t.replace("{n}",k);d.getElementById("anone").hidden=k>0}
  q.addEventListener("input",run);
  d.addEventListener("click",function(e){var c=e.target.closest(".topics [data-topic]");if(!c)return;tp=c.dataset.topic;d.querySelectorAll(".topics [data-topic]").forEach(function(b){b.setAttribute("aria-pressed",b===c)});run()})})();
JS

# ---- donate (#60: green poster band, real counts) ----

def build_donate(lang)
  p = lang_prefix(lang)
  dn = ->(k) { t(lang, "donate", k) }
  facts = ui(lang, "donate.facts").zip([RECIPES.size, articles_in(lang).size, 1]).map { |l, v| "<div><b>#{v}</b><span>#{h(l)}</span></div>" }.join
  main = <<~HTML
    <main>
    #{poster("Vegan", ui(lang, "donate.mark"), %(<span class="tag">#{h(ui(lang, "shell.more_links")[3])}</span><h1>#{h(dn["heading"])}</h1><p class="deck">#{h(dn["subtitle"])}</p>), mk: "--ms:190px;--my:-.22em;--mx:-.06em;--mr:-8deg")}
    <div class="col">
    <div class="facts">#{facts}</div>
    <div class="prose"><p>#{h(dn["paragraph_1"])}</p><p>#{h(dn["paragraph_2"])}</p></div>
    <a class="btn pri paypal" href="https://bit.ly/donateht" target="_blank" rel="noopener noreferrer">#{h(dn["donate_btn"])}#{ICON[:arr]}</a>
    <p class="thanks">#{h(dn["thank_you"])}</p>
    </div>
    </main>
  HTML
  head = shell_head(lang, title: dn["title"], description: dn["description"], page_path: "donate.html", og_image: SITE_OG, keywords: own(lang, "donate", "keywords"))
  write_page(lang, "donate.html", head, main, "donate.html")
end

# ---- the root 404 (#60): GitHub Pages serves only /404.html, for every language. The English page is the live body;
# the other four sit in <template>s and the one matching the URL's /pt|es|de|zh/ prefix replaces it before first paint.
# No canonical, no hreflang, no AdSense (no ads on error pages). js/shell.js suggests recipes from the broken URL. ----

# ---- about.html and contact.html (English only; #61: each file stays the source of its own copy). The build keeps the
# page's title, description, keywords and JSON-LD, rewraps the hand-maintained region between <!-- body --> markers in
# the shell, and refreshes the counts in about's facts row. Edit the copy inside the markers in the file itself. ----

def build_kept(file)
  f = File.join(ROOT_DIR, file)
  src = File.read(f)
  body = src[%r{<!-- body -->\n(.*?)<!-- /body -->}m, 1] or abort "ERROR: #{file} has no <!-- body --> … <!-- /body --> region"
  body = body.sub(/(data-count="recipes">)\d+/) { "#{$1}#{RECIPES.size}" }.sub(/(data-count="articles">)\d+/) { "#{$1}#{articles_in("en").size}" }
  meta = ->(n) { CGI.unescapeHTML(src[/<meta name="#{n}" content="([^"]*)"/, 1].to_s) }
  ld = src[%r{<script type="application/ld\+json">(.*?)</script>}m, 1]
  head = shell_head("en", title: CGI.unescapeHTML(src[%r{<title>(.*?)</title>}m, 1]), description: meta.("description"), page_path: file, og_image: SITE_OG,
                    structured: ld && JSON.generate(JSON.parse(ld)), keywords: meta.("keywords"), only_lang: true)
  write_file(f, head + shell_top("en") + "<!-- body -->\n#{body}<!-- /body -->\n" + shell_bottom("en", ""))
end

# The 4 starter recipes: the 404's suggestions with no URL match, and the articles' "Make your first batch".
STARTERS = %w[cannabutter pot-brownies gummy-bears pot-cookies].freeze

# ---- article pages (#60 "shell + type": no poster band). The body is injected unedited and styled only by the
# legacy-compat block in site.css; the build adds the TOC, the internal-link prefixes and the ad slots. ----

# #55: article-mid before the 3rd content H2 when the body has at least 4 (h2#sources doesn't count);
# article-end before h2#sources, or at the end of the body. body_html never stores a slot.
def article_slots(body, lang)
  abort "ERROR: an article body stores an ad slot; the build places them (#55)" if body.include?("adsbygoogle")
  h2s = body.to_enum(:scan, /<h2\b[^>]*>/).map { [$~.begin(0), $~[0]] }
  sources = h2s.find { |_, tag| tag.match?(/\bid="sources"/) }
  content = h2s - [sources]
  at = [[sources ? sources[0] : body.size, "article-end"]]
  at << [content[2][0], "article-mid"] if content.size >= 4
  at.sort.reverse.each_with_object(body.dup) { |(i, unit), b| b.insert(i, "#{ad_slot(lang, unit)}\n") }
end

def build_article_page(slug, lang)
  p = lang_prefix(lang)
  ai = ARTICLE_I18N.dig(lang, "articles_index") || {}
  a = ARTICLE_I18N.dig(lang, "articles", slug) or return
  title = a["title"] || slug
  page_path = "#{slug}.html"
  canonical = "#{SITE}#{p}/#{page_path}"
  arts = "#{p}/articles.html"
  # hreflang as before the redesign (every language that has the file); the switcher skips frozen pages too
  langs = ALL_LANGS.select { |l| ARTICLE_I18N.dig(l, "articles", slug) }
  switch = ALL_LANGS.to_h { |l| x = ARTICLE_I18N.dig(l, "articles", slug); [l, l == lang || (x && (l == "en" || !x["raw_main"])) ? page_path : "articles.html"] }
  head = ->(ld, og = SITE_OG) { shell_head(lang, title: "#{title} | HowToEdibles", description: a["description"] || "", page_path: page_path, og_image: og, og_title: title,
                             og_type: "article", structured: ld, keywords: a["keywords"] || "", langs: langs) }

  # Frozen orphan page (#71): body and JSON-LD verbatim, no ad slots (it can hold two article bodies). Two zh ones
  # carry the old shell's <script>s (jQuery, Bootstrap, dark-mode.js), which would fight the new shell: dropped.
  # ponytail: temporary until #44 publishes the 88 retranslations, which turns these into normal articles.
  if a["raw_main"]
    raw = a["raw_main"].gsub(%r{<script\b.*?</script>\s*}m, "")
    return write_page(lang, page_path, head.(JSON.generate(a["schema"])), %(<main class="col art">\n#{raw}\n</main>\n), switch)
  end

  card = article_card(lang, slug, a["short_title"] || title) # share card + Article image (#89)
  date_pub = a["date_published"] || "2026-03-05"
  date_mod = a["date_modified"] || date_pub
  ld = [
    { "@context" => "https://schema.org", "@type" => "Article", "headline" => title, "description" => a["description"] || "",
      "image" => card, "datePublished" => date_pub, "dateModified" => date_mod,
      "author" => { "@type" => "Organization", "name" => "HowToEdibles Editorial Team", "url" => "#{SITE}/about.html" },
      "publisher" => PUBLISHER,
      "mainEntityOfPage" => { "@type" => "WebPage", "@id" => canonical } },
    { "@context" => "https://schema.org", "@type" => "BreadcrumbList", "itemListElement" => [
      { "@type" => "ListItem", "position" => 1, "name" => ai["breadcrumb_home"] || "Home", "item" => "#{SITE}#{p}/" },
      { "@type" => "ListItem", "position" => 2, "name" => ai["breadcrumb_articles"] || "Articles", "item" => "#{SITE}#{arts}" },
      { "@type" => "ListItem", "position" => 3, "name" => title, "item" => canonical } ] },
    *a["schema_extra"],
  ]
  faq = a["faq"] || []
  ld << { "@context" => "https://schema.org", "@type" => "FAQPage", "mainEntity" => faq.map { |f| { "@type" => "Question", "name" => f["question"], "acceptedAnswer" => { "@type" => "Answer", "text" => f["answer"] } } } } unless faq.empty?

  toc = a["toc"] || []
  toc_html = toc.empty? ? "" : %(<div class="article-toc"><h4>#{h(ai["toc_title"] || "Table of Contents")}</h4><ul>#{toc.map { |x| %(<li><a href="##{x["id"]}">#{h(x["text"])}</a></li>) }.join}</ul></div>\n)
  # Prefix internal links, but only to pages that exist in this language; otherwise keep the English URL (never a 404).
  body = (a["body_html"] || "").gsub(/href="\/([^"\/]+)\.html(#[^"]*)?"/) do |m|
    ARTICLE_I18N.dig(lang, "articles", $1) || %w[calculator donate articles].include?($1) ? %(href="#{p}/#{$1}.html#{$2}") : m
  end
  body = body.include?("<!-- toc -->") ? body.sub("<!-- toc -->", toc_html) : toc_html + body

  related = (a["related"] || []).select { |r| ARTICLE_I18N.dig(lang, "articles", r["slug"]) }
  related_html = related.empty? ? "" : %(<div class="related-articles"><h3>#{h(ai["related_title"] || "Related Articles")}</h3><div class="row">) +
    related.map { |r| %(<div class="card"><h5 class="card-title"><a href="#{p}/#{r["slug"]}.html">#{h(r["title"])}</a></h5>#{r["description"] ? %(<p class="card-text">#{h(r["description"])}</p>) : ""}</div>) }.join + "</div></div>"

  date = ->(d) { lang == "en" ? Date.parse(d).strftime("%B %-d, %Y") : d }
  meta = [%(#{h(ai["byline"] || "By")} <a href="/about.html">HowToEdibles Editorial Team</a>), h(date.(date_pub))]
  meta << "#{h(ai["updated"] || "Updated")} #{h(date.(date_mod))}" if a["show_updated"]
  meta << h(a["read_time"] || "")
  crumb = h(ai["breadcrumb_articles"] || "Articles")
  starters = STARTERS.map { |s| card(RECIPES.find { |r| r["slug"] == s }, lang) }.join
  main = <<~HTML
    <main class="col art">
    <header class="ahead tone" style="#{cat_vars(TOPIC_COLOR[topic_of(slug)])}"><nav class="crumbs" aria-label="#{crumb}"><a href="#{arts}">#{crumb}</a><span aria-hidden="true">›</span><span class="tag">#{h(a["category"])}</span></nav>
    <h1>#{h(a["h1"] || title)}</h1><p class="lede article-excerpt">#{h(a["excerpt"])}</p><p class="byline article-meta">#{meta.map { |m| "<span>#{m}</span>" }.join}</p></header>
    <article class="article-body">
    #{article_slots(body, lang)}
    <div class="text-center mt-5"><a href="#{arts}" class="btn btn-success">#{h(ai["read_more_articles"] || "Read more articles")}</a></div>
    #{related_html}
    </article>
    <a class="band-calc next" href="#{p}/calculator.html"><span><b>#{h(ui(lang, "article.next_q"))}</b><span>#{h(ui(lang, "article.next_sub"))}</span></span><span class="go">#{ICON[:calc]}</span></a>
    <section class="block"><div class="bh"><h2>#{h(ui(lang, "article.first_batch"))}</h2><a href="#{p}/">#{h(ui(lang, "shell.all_recipes"))} →</a></div><div class="grid g4">#{starters}</div></section>
    </main>
  HTML
  write_page(lang, page_path, head.(JSON.generate(ld), card), main, switch)
end

def e404_body(lang)
  p = lang_prefix(lang)
  et = { looking: ui(lang, "e404.looking") }
  inner = %(<span class="tag">#{h(ui(lang, "e404.eyebrow"))}</span><h1>#{h(ui(lang, "e404.title"))}</h1><p class="deck">#{h(ui(lang, "e404.deck"))}</p><span class="url" hidden><s id="e404u"></s></span>)
  main = <<~HTML
    <main>
    #{poster("Desserts", "404", inner, cls: "lost", mk: "--my:-.16em;--mx:-.05em;--mr:-9deg")}
    <div class="col">
    <section class="block" id="e404" data-t="#{h(JSON.generate(et))}"><h2>#{h(ui(lang, "e404.popular"))}</h2><div class="grid g4">#{STARTERS.map { |s| card(RECIPES.find { |r| r["slug"] == s }, lang) }.join}</div></section>
    #{search_form(lang)}
    <div class="btns"><a class="btn" href="#{p}/calculator.html">#{ICON[:calc]}#{h(ui(lang, "shell.calc_card"))}</a><a class="btn pri" href="#{p}/">#{h(ui(lang, "shell.all_recipes"))}</a></div>
    </div>
    </main>
  HTML
  masthead(lang) + main + footer_dialogs(lang, "").chomp
end

def build_root_404
  tpl = (ALL_LANGS - ["en"]).map do |l|
    %(<template id="pg-#{l}" data-lang="#{lang_html(l)}" data-title="#{h(t(l, "page_404", "title"))}">#{e404_body(l)}</template>)
  end.join("\n")
  swap = %(<script>(function(){var m=/^\\/(pt|es|de|zh)(\\/|$)/.exec(location.pathname),t=m&&document.getElementById("pg-"+m[1]);if(!t)return;document.getElementById("pg").replaceWith(t.content);document.documentElement.lang=t.dataset.lang;document.title=t.dataset.title})()</script>\n)
  head = shell_head("en", title: t("en", "page_404", "title"), description: t("en", "page_404", "description"), page_path: "404.html", og_image: SITE_OG, indexed: false)
  page = head + %(<body>\n#{SPRITE_HTML}\n<div id="pg" style="display:contents">\n#{e404_body("en")}\n</div>\n#{tpl}\n) + scripts_tail(swap)
  write_file(File.join(ROOT_DIR, "404.html"), page)
end

# ─────────────────────────────────────────────
# Per-language search index (#73): fetched when the search sheet first opens
# ─────────────────────────────────────────────

def build_search_index(lang)
  cats = CAT_ORDER.map { |c| x = CAT_BY_NAME[c]["colors"]; [category_t(lang, c), x["cover"], x["glyph"], x["cover_dark"], x["glyph_dark"]] }
  rows = RECIPES.sort_by { |r| [r["position"].to_i, r["id"].to_i] }.map do |r|
    n = rname(r, lang)
    [r["slug"], n, n == r["name"] ? "" : r["name"], CAT_ORDER.index(r["category_name"]), fmt_mg(default_mg(r), lang), r["glyph"]]
  end
  write_file(File.join(ROOT_DIR, "data", "search-#{lang}.json"), JSON.generate({ "c" => cats, "r" => rows }))
end

# ─────────────────────────────────────────────
# og/schema rasters (#63 §5): one small HTML per raster, screenshotted by render_rasters.mjs
# ─────────────────────────────────────────────

RASTER_JOBS = []
RASTER_CSS = <<~CSS.gsub(/\n\s*/, "")
  @font-face{font-family:Unbounded;src:url(/fonts/unbounded-800.latin1.woff2) format("woff2");font-weight:800;font-display:block;unicode-range:U+0000-00FF,U+2013-2014,U+2018-2019,U+201C-201D,U+2022,U+2026,U+20AC,U+2212}
  *{box-sizing:border-box}html,body{margin:0}
  .cv{position:relative;overflow:hidden;display:block;background:var(--cat-lt);--cat:var(--cat-lt);--cat-deep:var(--deep-lt);color:#1f1410;font-family:Unbounded,"PingFang SC","Hiragino Sans GB","Noto Sans SC",sans-serif}
  .cv>svg{position:absolute;aspect-ratio:1;width:var(--gs);height:auto;right:var(--gx);bottom:var(--gy);transform:rotate(var(--gr))}
  .og{width:1200px;height:630px}.og>svg.g{width:auto;height:var(--gh)}
  .og.ph>img{position:absolute;top:-36px;right:0;width:64%;height:calc(100% + 36px);object-fit:cover;-webkit-mask-image:linear-gradient(to right,transparent,#000 45%);mask-image:linear-gradient(to right,transparent,#000 45%)}
  .sq{width:1200px;height:1200px}
  .cv>svg.logo{left:64px;top:56px;right:auto;bottom:auto;width:300px;height:auto;aspect-ratio:432/164;transform:none;--ink:#1f1410;--logo-o:#1f1410;--logo-g:#1f1410}
  h1{position:absolute;left:64px;bottom:64px;width:720px;margin:0;font-weight:800;font-size:76px;line-height:1.04;letter-spacing:-.03em;}.hy{hyphens:auto;-webkit-hyphens:auto}
  h1.mid{font-size:64px}h1.long{font-size:54px}:lang(zh) h1{font-weight:900;letter-spacing:0;line-height:1.18}
  .st{position:absolute;right:96px;bottom:96px;width:230px;height:230px;border-radius:50%;background:#1f1410;color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;transform:rotate(-8deg);box-shadow:0 0 0 8px #fff;line-height:1;text-align:center}
  .cv>.mk{position:absolute;right:-.04em;top:-.3em;font-size:620px;line-height:1;letter-spacing:-.06em;color:var(--cat-deep);transform:rotate(-8deg)}
  h1.a{width:960px;font-size:64px}h1.a.mid{font-size:56px}h1.a.long{font-size:48px}
  .og.ph .st{width:196px;height:196px;right:44px;bottom:44px}.og.ph .st b{font-size:62px!important}.og.ph .st b small{font-size:26px!important}.og.ph .st span{font-size:19px!important;margin-top:8px!important}
  .st b{font-size:72px;font-weight:800;letter-spacing:-.03em}.st b small{font-size:30px;letter-spacing:0}.st span{font-size:22px;font-weight:700;margin-top:10px;max-width:170px;line-height:1.1;font-family:-apple-system,"PingFang SC",sans-serif}
CSS

def raster_page(lang, body)
  %(<!DOCTYPE html><html lang="#{lang_html(lang)}"><head><meta charset="utf-8"><style>#{RASTER_CSS}</style></head><body>#{SPRITE_HTML}#{body}</body></html>)
end

# A share card with a photo is a JPEG (a PNG of a photo weighs ~270 KB, past WhatsApp's ~300 KB preview limit)
def recipe_og(lang, slug); "og/#{lang}/#{slug}.#{PHOTOS[slug] ? "jpg" : "png"}"; end

def raster_jobs(recipe, lang, name, mg)
  slug = recipe["slug"]
  cat = recipe["category_name"]
  pl = place(slug, :hero).map { |k, v| "--#{k}:#{v}" }.join(";")
  tc = title_class(name)
  # with a photo, it fades into the category colour on the right (as on the category band) instead of the glyph
  art = PHOTOS[slug] ? %(<img src="/images/photos/#{slug}-1200.webp" alt="">) : %(<svg class="g" viewBox="0 0 100 100"><use href="#g-#{recipe["glyph"]}"/></svg>)
  og = %(<div class="cv og#{PHOTOS[slug] ? " ph" : ""}" style="#{cat_vars(cat)};#{pl}">#{art}#{logo_svg}) +
       %(<h1#{tc ? %( class="#{tc}") : ""}>#{title_html(name, lang)}</h1><div class="st"><b>#{fmt_mg(mg, lang)}<small>mg</small></b><span>#{h(ui(lang, "calc.per"))}</span></div></div>)
  add_raster(recipe_og(lang, slug), raster_page(lang, og), 1200, 630)
  return unless lang == "en"
  sq = %(<div class="cv sq" style="#{cat_vars(cat)};#{place(slug, :card).map { |k, v| "--#{k}:#{v}" }.join(";")}">#{glyph_svg(recipe["glyph"])}</div>)
  add_raster("schema/#{slug}.png", raster_page(lang, sq), 1200, 1200)
end

# Article share card (#89): the topic colour with the title's first letter as the mark (as on the articles index),
# the logo and the title. It is also the Article JSON-LD image.
def article_card(lang, slug, title)
  n = title.each_char.sum { |c| c.match?(/[　-鿿]/) ? 1.7 : 1 }
  cls = n > 60 ? "a long" : n > 38 ? "a mid" : "a"
  html = %(<div class="cv og" style="#{cat_vars(TOPIC_COLOR[topic_of(slug)])}"><span class="mk">#{h(title.strip[0])}</span>#{logo_svg}<h1 class="#{cls}">#{title_html(title, lang)}</h1></div>)
  add_raster("og/#{lang}/a/#{slug}.png", raster_page(lang, html), 1200, 630)
  "#{SITE}/og/#{lang}/a/#{slug}.png"
end

def add_raster(out, html, w, h)
  rel = "tmp/rasters/#{out.sub(/\.(png|jpg)\z/, ".html")}"
  write_file(File.join(ROOT_DIR, rel), html)
  RASTER_JOBS << { "out" => out, "html" => rel, "width" => w, "height" => h }
end

def render_rasters
  write_file(File.join(ROOT_DIR, "tmp/rasters/jobs.json"), JSON.pretty_generate(RASTER_JOBS))
  abort "ERROR: render_rasters.mjs failed" unless system("node", File.join(__dir__, "render_rasters.mjs"))
end

# ─────────────────────────────────────────────
# Inbound-link gate (#73): every recipe, in every language, needs ≥ 2 static inbound links
# (its category page plus at least one "More {category}") and a sitemap entry.
# ─────────────────────────────────────────────

def check_inbound_links
  sitemap = File.read(File.join(ROOT_DIR, "sitemap.xml"))
  bad = []
  ALL_LANGS.each do |lang|
    inbound = Hash.new { |hh, k| hh[k] = Set.new }
    pages = Dir.glob(File.join(output_path(lang, "category"), "*/index.html")) + Dir.glob(File.join(output_path(lang, "recipes"), "*/index.html"))
    pages.each do |f|
      File.read(f).scan(%r{href="#{lang_prefix(lang)}/recipes/([a-z0-9-]+)/"}).flatten.uniq.each { |s| inbound[s] << f unless f.include?("/recipes/#{s}/") }
    end
    RECIPES.each do |r|
      from = inbound[r["slug"]]
      on_cat = from.any? { |f| f.include?("/category/") }
      bad << "#{lang} #{r["slug"]}: #{from.size} inbound#{on_cat ? "" : ", not on its category page"}" if from.size < 2 || !on_cat
      bad << "#{lang} #{r["slug"]}: missing from sitemap" unless sitemap.include?("<loc>#{SITE}#{recipe_url(lang, r)}</loc>")
    end
  end
  return puts("Inbound links: every recipe has ≥ 2 in all #{ALL_LANGS.size} languages, and a sitemap entry.") if bad.empty?
  puts "Inbound-link gate FAILED (#{bad.size}):", bad.first(20).map { |x| "  #{x}" }
  exit 1
end
