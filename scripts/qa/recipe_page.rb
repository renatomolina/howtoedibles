# Loads a site tree's recipe data and composes each recipe page's text the way build_redesign.rb#build_recipe_page does
# (ingredients, steps, template sections interpolated, the recipe's own *_unique sentences). Plain text, entities decoded.
# Usage from a script: require_relative "page"; site = Site.new(root); site.page(slug, lang)
require "json"
require "cgi"

LANGS = %w[en pt es de zh].freeze

class Site
  attr_reader :root, :recipes, :enrich, :i18n, :sections

  def initialize(root)
    @root = root
    j = ->(p) { JSON.parse(File.read(File.join(root, p))) }
    @recipes = j.("data/recipes.json")["recipes"]
    @enrich = j.("data/recipe_enrichment.json")
    @i18n = LANGS.drop(1).to_h { |l| [l, j.("i18n/recipes_#{l}.json")] }
    @sections = LANGS.to_h { |l| [l, j.("i18n/recipe_sections_#{l}.json")] }
    @by_slug = @recipes.to_h { |r| [r["slug"], r] }
    vp = File.join(root, "i18n/recipe_vars.json")
    @vars = File.exist?(vp) ? JSON.parse(File.read(vp)) : {}
  end

  def recipe(slug); @by_slug.fetch(slug); end
  def rt(lang, slug, k); lang == "en" ? nil : @i18n.dig(lang, slug, k); end

  ENT = { "&deg;" => "°", "&nbsp;" => " ", "&frac12;" => "½", "&frac14;" => "¼", "&frac34;" => "¾", "&ndash;" => "–", "&mdash;" => "—",
          "&rsquo;" => "’", "&lsquo;" => "‘", "&ldquo;" => "“", "&rdquo;" => "”", "&eacute;" => "é", "&amp;" => "&", "&quot;" => '"', "&#39;" => "'" }.freeze
  def self.plain(s); CGI.unescapeHTML(s.to_s.gsub(/<[^>]+>/, " ").gsub(/&[a-z0-9]+;|&#\d+;/i) { |e| ENT[e] || e }).gsub(/\s+/, " ").strip; end

  def interpolate(t, vars)
    r = t.dup
    vars.each { |k, v| r.gsub!("%{#{k}}", v.to_s) }
    r.gsub(/\b(cannabis)\s+(cannabis|cannabutter)\b/i) { $2.casecmp?("cannabis") ? $1 : $2 }
  end

  # Returns { ings:, steps:, intro:, tips:, mistakes:, storage:, variations:, faq: [[q,a]], unique: {k=>text}, tmpl_key: }
  # Template-sourced lines and the recipe's own lines are kept apart (:tmpl / :own) so failures can name their source.
  def page(slug, lang)
    r = recipe(slug)
    e = @enrich[slug] || {}
    li = ->(html) { html.to_s.scan(%r{<li[^>]*>(.*?)</li>}m).map { |m| m[0] } }
    ings = rt(lang, slug, "ingredients")
    ings = li.(r["ingredients"]) unless ings.is_a?(Array) && !ings.empty?
    # the flower amount the build replaces with suggested_quantity (build_redesign.rb#recipe_lines / ingredient_html)
    gq = r["suggested_quantity"].to_f
    gs = gq == gq.round ? gq.round.to_s : gq.round(gq < 1 ? 2 : 1).to_s
    ings = ings.map do |x|
      x.gsub(%r{<span id="grams-quantity-recipe">[^<]*</span>}, gs)
       .sub(lang == "en" ? /(?!)/ : /(\d+(?:[.,]\d+)?)(\s*(?:gramas?\b|gramos?\b|Gramm\b|g\b|克))?(\s*(?:de\s+)?)(ground\s*weed|maconha triturada|erva moída|cannabis moída|marihuana molida|hierba molida|cannabis molida|gemahlenes Gras|gemahlenes Cannabis|研磨好的大麻|研磨大麻)/i) { "#{gs}#{$2 || " g"}#{$3.empty? && !$2 ? " " : $3}#{$4}" }
    end
    steps = rt(lang, slug, "instructions")
    steps = li.(r["instructions"]) unless steps.is_a?(Array) && !steps.empty?
    name = rt(lang, slug, "name") || r["name"]
    sub = e["sub_category"] || "general"
    tcat, tsub = sub.include?("/") ? sub.split("/", 2) : [r["category_name"], sub]
    tmpl = @sections.dig(lang, "templates", tcat, tsub) || @sections.dig("en", "templates", tcat, tsub) || {}
    # the translated value of %{base_fat}/%{cook_temp} (i18n/recipe_vars.json, #92), as the build does; English otherwise
    fat_en, temp_en = e["base_fat"] || "cannabutter", e["cook_temp"] || "350°F / 180°C"
    vars = { "name" => name, "base_fat" => (@vars.dig(lang, "base_fat", fat_en) || [fat_en])[0], "cook_temp" => @vars.dig(lang, "cook_temp", temp_en) || temp_en, "category" => r["category_name"] }
    ip = ->(x) { Site.plain(interpolate(x, vars)) }
    own = %w[intro_unique dosing_unique storage_unique variation_unique].to_h { |k| [k, Site.plain(rt(lang, slug, k) || e[k] || "")] }
    {
      slug: slug, lang: lang, name: name, cat: r["category_name"], sub: sub, enrich: e,
      g: r["suggested_quantity"].to_f, n: r["suggested_portion"].to_f,
      ings: ings.map { |x| Site.plain(x) }, steps: steps.map { |x| Site.plain(x) },
      desc: Site.plain(rt(lang, slug, "description") || r["description"]),
      tmpl: {
        "intro" => [ip.(tmpl["intro"] || "")].reject(&:empty?),
        "dosing_tips" => (tmpl["dosing_tips"] || []).map(&ip),
        "common_mistakes" => (tmpl["common_mistakes"] || []).map(&ip),
        "storage" => (tmpl["storage"] || []).map(&ip),
        "variations" => (tmpl["variations"] || []).map(&ip),
        "faq" => (tmpl["faq"] || []).select { |f| !f["only"] || f["only"].include?(slug) }.map { |f| "#{ip.(f["q"])} #{ip.(f["a"])}" },
      },
      own: own,
      raw_tmpl: tmpl,
    }
  end

  # every text block on the page with its source label, for whole-page scans
  def blocks(p)
    out = []
    out << ["description", p[:desc]]
    p[:ings].each_with_index { |x, i| out << ["ingredient #{i + 1}", x] }
    p[:steps].each_with_index { |x, i| out << ["step #{i + 1}", x] }
    p[:tmpl].each { |k, l| l.each_with_index { |x, i| out << ["template #{p[:cat]}/#{p[:sub]}.#{k}[#{i}]", x] } }
    p[:own].each { |k, x| out << ["own #{k}", x] unless x.empty? }
    out
  end
end
