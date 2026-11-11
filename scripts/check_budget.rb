#!/usr/bin/env ruby
# Page-weight budget for the deploy tree, from "What is the performance budget for the
# new pages?" (#63 §2, §7). Sizes are gzipped as transferred (woff2 counted raw).
# Called at the end of build_site.rb. Run alone: ruby scripts/check_budget.rb
#
# BLOCKING for every page and the shared assets (site.css, the font, the search indexes): since
# Phase 4 (#76) no page is left on the old shell.
require "zlib"

ROOT = File.expand_path("..", __dir__)
KB = 1024

BUDGET = {
  html: 35 * KB, home_html: 45 * KB, site_css: 20 * KB, font: 20 * KB,
  js: 12 * KB, critical: 90 * KB, search_index: 30 * KB,
}.freeze

def gz(path)
  Zlib.gzip(File.binread(path), level: 9).bytesize
end

def kb(bytes)
  format("%.1f KB", bytes / 1024.0)
end

# Everything GitHub Pages serves, minus local-only dirs (prototypes never reach master).
def deployed(glob)
  Dir.glob(glob, base: ROOT).reject { |p| p.match?(%r{\A(tmp|node_modules|old_rails)/|(\A|/)[._]}) }
end

# A root-relative or relative URL in a page → file on disk, or nil if off-site.
def local_file(page, url)
  return nil if url.match?(%r{\A(https?:)?//|\Adata:})
  path = url.sub(/[?#].*/, "")
  file = path.start_with?("/") ? File.join(ROOT, path) : File.join(ROOT, File.dirname(page), path)
  File.file?(file) ? file : nil
end

block = Hash.new { |h, k| h[k] = [] } # rule → [[detail, bytes]]
size_cache = Hash.new { |h, f| h[f] = f.end_with?(".woff2") ? File.size(f) : gz(f) }

deployed("**/*.html").each do |page|
  html = File.read(File.join(ROOT, page))
  hits = block
  home = page.match?(%r{\A([a-z]{2}/)?index\.html\z})
  html_gz = size_cache[File.join(ROOT, page)]
  limit = home ? BUDGET[:home_html] : BUDGET[:html]
  hits["HTML > #{kb(limit)}#{' (home)' if home}"] << [page, html_gz] if html_gz > limit

  tags = html.scan(/<(?:link|script)\b[^>]*>/i)
  css = tags.grep(/rel=["']?stylesheet/i).filter_map { |t| t[/href=["']?([^"'\s>]+)/i, 1] }
  scripts = tags.grep(/\A<script/i).filter_map { |t| [t, t[/src=["']?([^"'\s>]+)/i, 1]] if t.match?(/\ssrc=/i) }
  fonts = tags.grep(/rel=["']?preload/i).grep(/as=["']?font/i).filter_map { |t| t[/href=["']?([^"'\s>]+)/i, 1] }

  css.reject { |u| local_file(page, u) }.each { |u| hits["cross-origin stylesheet"] << ["#{page} → #{u}", 0] }
  scripts.each do |tag, src|
    sync = !tag.match?(/\s(async|defer)\b/i) && !tag.match?(/type=["']?module/i)
    hits["synchronous <script src>"] << ["#{page} → #{src}", 0] if sync
  end

  js = scripts.filter_map { |_, src| local_file(page, src) }.uniq.sum { |f| size_cache[f] }
  hits["first-party JS > #{kb(BUDGET[:js])}"] << [page, js] if js > BUDGET[:js]

  critical = html_gz + (css + fonts).filter_map { |u| local_file(page, u) }.uniq.sum { |f| size_cache[f] }
  hits["critical path > #{kb(BUDGET[:critical])}"] << [page, critical] if critical > BUDGET[:critical]
end

{ "css/site.css" => :site_css, "fonts/unbounded-800.latin1.woff2" => :font }.each do |rel, key|
  file = File.join(ROOT, rel)
  next unless File.file?(file)
  block["#{rel} > #{kb(BUDGET[key])}"] << [rel, size_cache[file]] if size_cache[file] > BUDGET[key]
end

deployed("**/search*.json").each do |rel|
  bytes = size_cache[File.join(ROOT, rel)]
  block["search index > #{kb(BUDGET[:search_index])}"] << [rel, bytes] if bytes > BUDGET[:search_index]
end

report = lambda do |title, set|
  puts title
  set.each do |rule, list|
    worst = list.uniq.sort_by { |_, b| -b }.first(3).map { |d, b| b.positive? ? "#{d} (#{kb(b)})" : d }
    puts "  #{rule}: #{list.size} — e.g. #{worst.join(', ')}"
  end
end
report.("Budget FAILED:", block) unless block.empty?
puts "Budget: every page and the shared assets within limits." if block.empty?
exit(block.empty? ? 0 : 1)
