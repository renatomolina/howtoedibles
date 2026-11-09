# Summarise Lighthouse JSON reports: ruby lh-summary.rb report1.json report2.json ...
require "json"

AUDITS = %w[largest-contentful-paint cumulative-layout-shift total-blocking-time first-contentful-paint speed-index
            interaction-to-next-paint render-blocking-resources unused-css-rules unused-javascript uses-responsive-images
            font-display font-size target-size color-contrast image-size-responsive dom-size third-party-summary
            largest-contentful-paint-element layout-shifts]

ARGV.each do |f|
  r = JSON.parse(File.read(f))
  puts "## #{r['finalDisplayedUrl']}"
  puts "Scores: " + r["categories"].map { |k, c| "#{k} #{(c['score'] * 100).round}" }.join(", ")
  AUDITS.each do |id|
    a = r["audits"][id] or next
    next if a["score"] == 1 && !%w[largest-contentful-paint cumulative-layout-shift total-blocking-time].include?(id)
    line = "- #{id}: #{a['displayValue'] || a['score']}"
    items = a.dig("details", "items") || []
    items = items.flat_map { |i| i["items"] || [i] } if id.include?("element") || id == "layout-shifts"
    samples = items.first(4).map { |i| (i.dig("node", "snippet") || i["url"] || i.dig("entity", "text") || i["entity"]).to_s[0, 110] }.reject(&:empty?)
    line += " | " + samples.join(" ; ") unless samples.empty?
    puts line
  end
  puts
end
