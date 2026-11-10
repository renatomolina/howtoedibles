# scripts/build_redesign.rb — the redesign's shell and page templates (#72 Phase 1a, #73 Phase 1b).
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
# Group by category_name: recipes.json → categories[].recipes is stale (137 of 237).
RECIPES_BY_CAT = CAT_ORDER.to_h { |c| [c, RECIPES.select { |r| r["category_name"] == c }.sort_by { |r| [r["position"].to_i, r["id"].to_i] }] }
abort "ERROR: recipes outside the 8 categories" unless RECIPES_BY_CAT.values.sum(&:size) == RECIPES.size
POPULAR = %w[cannabutter pot-brownies gummy-bears pot-cookies infused-coconut-oil].freeze # ponytail: placeholder until GSC/GA4 says what's most made
LEARN = %w[cannabis-edibles-for-beginners how-long-do-edibles-take-to-kick-in science-of-decarboxylation how-to-prevent-a-bad-trip].freeze
HELP_URL = "https://bit.ly/helpimhavingabadtrip"
SITE = "https://www.howtoedibles.com"
LANG_LABEL = { "en" => "EN", "pt" => "PT", "es" => "ES", "de" => "DE", "zh" => "中文" }.freeze
AD_CLIENT = "ca-pub-6354522716906819"
# ponytail: the 8 per-position units (#55) aren't created in AdSense yet; until the owner sends their
# ids, the two existing units stand in. Swap the ids here when they exist.
AD_UNITS = { "recipe-mid" => "4353785890", "recipe-end" => "5475295879", "category" => "4353785890" }.freeze

SPRITE = File.read(File.join(ROOT_DIR, "data", "glyphs.svg")).sub(/\A.*?<svg[^>]*>/m, "").sub(%r{</svg>\s*\z}, "").gsub(/<!--.*?-->\n?/m, "").strip

# The C2 logo as one <symbol>: the wordmark is the only part that changes in dark mode
# (logo.svg vs logo-dark.svg), so it takes var(--ink) and one symbol serves both themes.
def logo_symbol
  light = File.read(File.join(ROOT_DIR, "images/brand/logo.svg"))
  dark = File.read(File.join(ROOT_DIR, "images/brand/logo-dark.svg"))
  # The exported viewBox is the fill bbox; strokes reach 5.5 units past it, so pad 6 on every side.
  x, y, w, hh = light[/viewBox="([^"]+)"/, 1].split.map(&:to_f)
  view_box = [x - 6, y - 6, w + 12, hh + 12].map { |v| v.round(2) }.join(" ")
  a, b = light.split(/(?=<)/), dark.split(/(?=<)/)
  abort "ERROR: logo.svg and logo-dark.svg differ in structure" unless a.size == b.size
  body = a.zip(b).map { |x, y| x == y ? x : x.sub(/fill="[^"]+"/, 'fill="var(--ink)"') }.join
  inner = body.sub(/\A.*?<svg[^>]*>/m, "").sub(%r{</svg>\s*\z}, "")
  %(<symbol id="logo" viewBox="#{view_box}">#{inner.strip}</symbol>)
end
LOGO_SYMBOL = logo_symbol
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

def cover(slug, cat, glyph, kind, inner = "")
  style = [cat_vars(cat), *place(slug, kind).map { |k, v| "--#{k}:#{v}" }].join(";")
  %(<span class="cv" style="#{style}">#{glyph_svg(glyph)}#{inner}</span>)
end

def cat_url(lang, cat); "#{lang_prefix(lang)}/category/#{CAT_BY_NAME.fetch(cat)["slug"]}/"; end
def recipe_url(lang, r); "#{lang_prefix(lang)}/recipes/#{r["slug"]}/"; end

def card(r, lang)
  mg = fmt_mg(default_mg(r), lang)
  dot = %(<span class="dot" title="#{mg} mg THC #{h(ui(lang, "calc.per"))}"><b>#{mg}</b><small>mg</small></span>)
  %(<a class="card" href="#{recipe_url(lang, r)}">#{cover(r["slug"], r["category_name"], r["glyph"], :card, dot)}<span class="nm">#{h(rname(r, lang))}</span></a>)
end

def cat_tile(lang, cat, with_count: true)
  inner = %(<b>#{h(category_t(lang, cat))}</b>) + (with_count ? %(<small>#{h(ui(lang, "shell.n_recipes", n: RECIPES_BY_CAT[cat].size))}</small>) : "")
  %(<a href="#{cat_url(lang, cat)}">#{cover(cat, cat, CAT_GLYPH[cat], :tile, inner)}</a>)
end

# Search sheet tile: the name sits under the cover.
def cat_square(lang, cat); %(<a href="#{cat_url(lang, cat)}">#{cover(cat, cat, CAT_GLYPH[cat], :card)}#{h(category_t(lang, cat))}</a>); end

def ad_slot(lang, unit)
  label = h(ui(lang, "ad.label"))
  %(<aside class="ad" aria-label="#{label}"><small>#{label}</small><ins class="adsbygoogle" style="display:block" data-ad-client="#{AD_CLIENT}" data-ad-slot="#{AD_UNITS.fetch(unit)}" data-ad-format="auto" data-full-width-responsive="true"></ins><script>(adsbygoogle=window.adsbygoogle||[]).push({});</script></aside>)
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

def shell_head(lang, title:, description:, page_path:, og_image:, og_title: title, og_type: "website", structured: nil)
  canonical = "#{SITE}#{lang_prefix(lang)}/#{page_path}"
  ld = structured ? %(\n<script type="application/ld+json">#{structured}</script>) : ""
  <<~HTML
    <!DOCTYPE html>
    <!-- Generated by scripts/build_site.rb from data/ and i18n/ — edit the source, not this file -->
    <html lang="#{lang_html(lang)}">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>#{h(title)}</title>
    <meta name="description" content="#{h(description)}">
    <link rel="canonical" href="#{canonical}">
    <link rel="icon" type="image/x-icon" href="/favicon_385_icon.ico">
    <meta property="og:type" content="#{og_type}">
    <meta property="og:site_name" content="HowToEdibles">
    <meta property="og:title" content="#{h(og_title)}">
    <meta property="og:description" content="#{h(description)}">
    <meta property="og:image" content="#{og_image}">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:url" content="#{canonical}">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="#{h(og_title)}">
    <meta name="twitter:description" content="#{h(description)}">
    <meta name="twitter:image" content="#{og_image}">
    <meta name="google-site-verification" content="Gx8tQ2a4mdwxSkH2HQSVZa8Iwm8EW6nSTSO3PhERQNY">
    #{hreflang_tags(page_path).gsub(" />", ">")}
    <link rel="preload" href="/fonts/unbounded-800.latin1.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="stylesheet" href="/css/site.css">
    #{THEME_BOOT}
    <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=#{AD_CLIENT}" crossorigin="anonymous"></script>#{ld}
    </head>
  HTML
end

def logo_svg(cls = "logo", label: nil)
  aria = label ? %(role="img" aria-label="#{label}") : %(aria-hidden="true")
  %(<svg class="#{cls}" viewBox="#{LOGO_SYMBOL[/viewBox="([^"]+)"/, 1]}" width="240" height="89" #{aria}><use href="#logo"/></svg>)
end

def shell_top(lang)
  p = lang_prefix(lang)
  <<~HTML
    <body>
    #{SPRITE_HTML}
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

def menu_dialog(lang, page_path)
  p = lang_prefix(lang)
  langs = ALL_LANGS.map { |l| %(<a href="#{lang_prefix(l)}/#{page_path}" lang="#{lang_html(l)}" hreflang="#{lang_html(l)}"#{l == lang ? ' aria-current="true"' : ""}>#{LANG_LABEL[l]}</a>) }.join
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

def shell_bottom(lang, page_path, scripts: "")
  p = lang_prefix(lang)
  more = ui(lang, "shell.more_links")
  more_links = [["#{p}/calculator.html", more[0]], ["/about.html", more[1]], ["/contact.html", more[2]], ["#{p}/donate.html", more[3]]]
  langs = ALL_LANGS.map { |l| %(<a href="#{lang_prefix(l)}/#{page_path}" lang="#{lang_html(l)}" hreflang="#{lang_html(l)}"#{l == lang ? ' aria-current="true"' : ""}>#{LANG_LABEL[l]}</a>) }.join
  <<~HTML
    </div>
    <footer class="ftr"><div class="wrap">
    <nav class="cols" aria-label="#{h(ui(lang, "shell.recipes"))}"><h2>#{h(ui(lang, "shell.recipes"))}</h2>#{CAT_ORDER.map { |c| %(<a href="#{cat_url(lang, c)}">#{h(category_t(lang, c))}</a>) }.join}
    <h2>#{h(ui(lang, "shell.learn"))}</h2>#{learn_links(lang).map { |u, n| %(<a href="#{u}">#{h(n)}</a>) }.join}<a href="#{HELP_URL}" target="_blank" rel="noopener">#{h(ui(lang, "shell.help"))}</a>
    <h2>#{h(ui(lang, "shell.more"))}</h2>#{more_links.map { |u, n| %(<a href="#{u}">#{h(n)}</a>) }.join}</nav>
    <div class="langs">#{langs}</div>
    <p>#{h(ui(lang, "shell.legal"))}</p>
    </div></footer>
    #{search_dialog(lang)}#{menu_dialog(lang, page_path)}#{scripts}<script src="/js/shell.js" defer></script>
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-MGB628XR50"></script>
    <script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag("js",new Date());gtag("config","G-MGB628XR50");</script>
    </body>
    </html>
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
    line.sub(FAT_RE) { %(<a href="#{lang_prefix(lang)}/recipes/cannabutter/">#{$1}</a><a class="make-first" href="#{lang_prefix(lang)}/recipes/cannabutter/">#{h(first)}</a>) }
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
    "image" => "#{SITE}/schema/#{slug}.png",
    "author" => { "@type" => "Organization", "name" => "HowToEdibles", "url" => SITE },
    "publisher" => { "@type" => "Organization", "name" => "HowToEdibles", "url" => SITE, "logo" => { "@type" => "ImageObject", "url" => "#{SITE}/images/brand/logo.png" } },
    "datePublished" => recipe["id"].to_i <= 140 ? "2024-06-01" : "2026-03-15", "dateModified" => "2026-03-15",
    "recipeCategory" => recipe_t(lang, slug, "category_name") || cat,
    "recipeYield" => [fmt_num(n), "#{fmt_num(n)} servings"],
    "recipeIngredient" => (recipe_t(lang, slug, "ingredients") || ings).map(&plain), # the source text, as before the redesign
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
  ld = [schema, crumbs, build_recipe_faq_schema(recipe, lang)].compact

  # ---- long-tail sections (template text + the recipe's own sentences)
  sub = enrich["sub_category"] || "general"
  tmpl = get_recipe_section_template(lang, cat, sub)
  vars = { "name" => name, "base_fat" => enrich["base_fat"] || "cannabutter", "cook_temp" => enrich["cook_temp"] || "350°F / 180°C", "category" => cat }
  own = ->(k) { x = recipe_t(lang, slug, k) || enrich[k]; x && !x.empty? ? [x] : [] }
  list = ->(k, u = nil) { (tmpl[k] || []).map { |x| interpolate(x, vars) } + (u ? own.(u) : []) }
  label = ->(k) { interpolate(get_section_label(lang, k), vars) }
  intro = "#{interpolate(tmpl["intro"] || "", vars.merge("name" => name.downcase))} #{own.("intro_unique").first}".strip
  tips = list.("dosing_tips", "dosing_unique")
  accs = [["common_mistakes", list.("common_mistakes")], ["storage", list.("storage", "storage_unique")], ["variations", list.("variations", "variation_unique")]].reject { |_, l| l.empty? }
  faqs = (tmpl["faq"] || []).map { |f| [interpolate(f["q"], vars), interpolate(f["a"], vars)] }
  ul = ->(l) { %(<ul class="tips">#{l.map { |x| "<li>#{x}</li>" }.join}</ul>) }
  pm = %(<span class="pm">#{ICON[:plus]}</span>)

  total = iso_minutes(enrich["totalTime"]).nonzero? || iso_minutes(enrich["prepTime"]) + iso_minutes(enrich["cookTime"])
  tc = title_class(name)
  adj_sub = ui(lang, "recipe.adjust_sub", g: fmt_g(g, lang), p: nf(s, 1, lang))
  wake = ->(cls = "") { %(<button type="button" class="wake #{cls}" data-wake aria-pressed="false"><span class="dot">#{ICON[:sun]}</span><span>#{h(ui(lang, "recipe.wake"))}</span></button>) }
  summary = interpolate(t(lang, "calculator", "dose_summary"), "grams" => nf(g, 2, lang), "potency" => nf(s, 1, lang), "servings" => nf(n, 0, lang), "mg" => nf(mg, 1, lang))

  presets = {
    "g" => [3.5, 7, 14, 28].each_with_index.map { |v, i| [v, "#{fmt_g(v, lang)} g", ui(lang, "calc.oz")[i]] },
    "s" => [[8, t(lang, "calculator", "potency_low")], [14, ui(lang, "calc.average")], [22, t(lang, "calculator", "potency_high")], [60, t(lang, "calculator", "potency_concentrates")]].map { |v, l| [v, "#{v}%", l] },
    "n" => [[n_i, n_i.to_s, ui(lang, "calc.this_recipe")]] + [12, 24, 50].reject { |v| v == n_i }.map { |v| [v, v.to_s, nil] },
  }
  cur = { "g" => g, "s" => s, "n" => n_i }
  qs = { "g" => t(lang, "calculator", "weed_quantity"), "s" => t(lang, "calculator", "weed_strength"), "n" => t(lang, "calculator", "portions_question") }
  units = { "g" => ui(lang, "calc.g"), "s" => "% #{ui(lang, "calc.thc")}", "n" => servings_word(lang, n_i) }
  vals = { "g" => fmt_g(g, lang), "s" => nf(s, 1, lang), "n" => n_i.to_s }
  rows = %w[g s n].map do |k|
    chips = presets[k].map { |v, a, b| %(<button type="button" class="chip" data-k="#{k}" data-v="#{v}" aria-pressed="#{cur[k] == v}">#{a}#{b ? "<small>#{h(b)}</small>" : ""}</button>) }.join
    %(<div class="row"><label class="q" for="in-#{k}">#{h(qs[k])}</label><div class="stepper"><button type="button" class="rnd" data-step="#{k}" data-d="-1" aria-label="−">#{ICON[:minus]}</button>) +
      %(<span class="fld"><input id="in-#{k}" data-in="#{k}" inputmode="decimal" enterkeyhint="done" autocomplete="off" value="#{vals[k]}"><span class="u" data-unit="#{k}">#{h(units[k])}</span></span>) +
      %(<button type="button" class="rnd" data-step="#{k}" data-d="1" aria-label="+">#{ICON[:plus]}</button></div><div class="chips" role="group" aria-label="#{h(qs[k])}">#{chips}</div></div>)
  end.join

  main = <<~HTML
    <main class="page">
    <section class="hero#{tc ? " #{tc}" : ""}" style="#{cat_vars(cat)}">#{cover(slug, cat, recipe["glyph"], :hero)}<a class="crumb" href="#{cat_url(lang, cat)}">#{h(cat_t)}</a>
    <a class="sticker" href="#dose" id="sticker"><b data-o="mgs">#{fmt_mg(mg, lang)}<small>mg</small></b><span>#{h(ui(lang, "calc.per"))}</span></a>
    <span class="sticker-room" aria-hidden="true"></span><h1>#{title_html(name, lang)}</h1>
    <div class="facts"><div><b>#{duration(lang, total)}</b><span>#{h(ui(lang, "recipe.total"))}</span></div><div><b data-o="n">#{n_i}</b><span>#{h(ui(lang, "recipe.makes"))}</span></div><div><b data-o="batch">#{fmt_mg(mg * n, lang)} mg</b><span>#{h(ui(lang, "calc.batch"))}</span></div></div>
    <p class="newbie">#{ICON[:warn]}<span data-o="newbie">#{newbie_html(lang, mg)}</span></p>
    <div class="cta"><a class="btn" href="#dose">#{ICON[:dial]}<span>#{h(ui(lang, "recipe.adjust"))}<small data-o="adj">#{h(adj_sub)}</small></span></a><a class="btn pri" href="#recipe">#{h(ui(lang, "recipe.jump"))}#{ICON[:down]}</a></div></section>
    <div class="intro"><p>#{h(desc)}</p>#{intro.empty? ? "" : "<p>#{intro}</p>"}</div>
    <div class="rail"><section class="block" id="dose"><h2>#{h(ui(lang, "calc.your_dose"))}</h2><p class="hint">#{h(summary)}</p>
    <div class="calc" id="calc"><div class="peek" aria-hidden="true" id="peek" style="--lc:#{LEVEL_COLORS[lvl_idx(mg)]}">#{peek_html(lang, g, s, n)}</div><div class="res" aria-live="polite" id="live">#{live_html(lang, g, s, n)}</div>
    <div class="ins">#{rows}</div>
    <div class="cfoot"><a href="#{p}/calculator.html">#{h(ui(lang, "calc.full"))}</a><a href="#{p}/calculator.html#potency">#{h(ui(lang, "calc.guide"))}</a><button type="button" class="reset" data-reset hidden>#{h(ui(lang, "calc.reset_recipe"))}</button></div></div>
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
  scripts = %(<script>window.RECIPE_DEFAULTS={quantity:#{g},potency:#{s},portion:#{n_i}};window.DOSE=#{JSON.generate(dose)};</script>\n<script src="/js/dose.js" defer></script>\n)
  page = shell_head(lang, title: "#{name} #{t(lang, "recipe_page", "title_suffix")}", description: desc, page_path: page_path,
                    og_image: "#{SITE}/og/#{lang}/#{slug}.png", og_type: "article", structured: JSON.generate(ld))
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
  main = <<~HTML
    <main>
    <section class="band" style="#{cat_vars(cat)}">#{glyph_svg(CAT_GLYPH[cat])}<a class="back" href="#{p}/">← #{h(ui(lang, "shell.all_recipes"))}</a><h1>#{h(cat_t)}</h1><p>#{h(lede)}</p></section>
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
  page = shell_head(lang, title: "#{cat_t} · #{ui(lang, "shell.n_recipes", n: list.size)} | HowToEdibles", description: desc,
                    page_path: page_path, og_image: "#{SITE}/images/brand/og-image.jpg", structured: JSON.generate(ld))
  page << shell_top(lang) << main << shell_bottom(lang, page_path)
  write_file(output_path(lang, "category", slug, "index.html"), page)
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
  .sq{width:1200px;height:1200px}
  .cv>svg.logo{left:64px;top:56px;right:auto;bottom:auto;width:300px;height:auto;aspect-ratio:370.75/138;transform:none;--ink:#1f1410}
  h1{position:absolute;left:64px;bottom:64px;width:720px;margin:0;font-weight:800;font-size:76px;line-height:1.04;letter-spacing:-.03em;}.hy{hyphens:auto;-webkit-hyphens:auto}
  h1.mid{font-size:64px}h1.long{font-size:54px}:lang(zh) h1{font-weight:900;letter-spacing:0;line-height:1.18}
  .st{position:absolute;right:96px;bottom:96px;width:230px;height:230px;border-radius:50%;background:#1f1410;color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;transform:rotate(-8deg);box-shadow:0 0 0 8px #fff;line-height:1;text-align:center}
  .st b{font-size:72px;font-weight:800;letter-spacing:-.03em}.st b small{font-size:30px;letter-spacing:0}.st span{font-size:22px;font-weight:700;margin-top:10px;max-width:170px;line-height:1.1;font-family:-apple-system,"PingFang SC",sans-serif}
CSS

def raster_page(lang, body)
  %(<!DOCTYPE html><html lang="#{lang_html(lang)}"><head><meta charset="utf-8"><style>#{RASTER_CSS}</style></head><body>#{SPRITE_HTML}#{body}</body></html>)
end

def raster_jobs(recipe, lang, name, mg)
  slug = recipe["slug"]
  cat = recipe["category_name"]
  pl = place(slug, :hero).map { |k, v| "--#{k}:#{v}" }.join(";")
  tc = title_class(name)
  og = %(<div class="cv og" style="#{cat_vars(cat)};#{pl}"><svg class="g" viewBox="0 0 100 100"><use href="#g-#{recipe["glyph"]}"/></svg>#{logo_svg}) +
       %(<h1#{tc ? %( class="#{tc}") : ""}>#{title_html(name, lang)}</h1><div class="st"><b>#{fmt_mg(mg, lang)}<small>mg</small></b><span>#{h(ui(lang, "calc.per"))}</span></div></div>)
  add_raster("og/#{lang}/#{slug}.png", raster_page(lang, og), 1200, 630)
  return unless lang == "en"
  sq = %(<div class="cv sq" style="#{cat_vars(cat)};#{place(slug, :card).map { |k, v| "--#{k}:#{v}" }.join(";")}">#{glyph_svg(recipe["glyph"])}</div>)
  add_raster("schema/#{slug}.png", raster_page(lang, sq), 1200, 1200)
end

def add_raster(out, html, w, h)
  rel = "tmp/rasters/#{out.sub(/\.png\z/, ".html")}"
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
