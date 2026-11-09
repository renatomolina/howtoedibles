# Lighthouse mobile runs, one at a time (parallel runs skew perf numbers): ruby lh-run.rb
# Ads are left on: Lighthouse's UA is filtered by Google as a bot, and ad-driven CLS is part of what we measure.
dir = File.join(__dir__, "lighthouse")
Dir.mkdir(dir) unless Dir.exist?(dir)
{
  "en-home" => "/", "en-recipe-photo" => "/recipes/cannabutter/", "en-recipe-placeholder" => "/recipes/pot-brownies/",
  "en-calculator" => "/calculator.html", "en-article" => "/how-long-do-edibles-take-to-kick-in.html",
  "de-home" => "/de/", "zh-recipe-placeholder" => "/zh/recipes/pot-brownies/",
}.each do |name, path|
  out = File.join(dir, "#{name}.json")
  next if File.exist?(out)
  ok = system("npx", "-y", "lighthouse@12", "https://www.howtoedibles.com#{path}", "--form-factor=mobile", "--output=json",
              "--output-path=#{out}", "--chrome-flags=--headless=new", "--quiet",
              "--only-categories=performance,accessibility,best-practices,seo")
  puts "#{name}: #{ok ? 'ok' : 'FAILED'}"
end
