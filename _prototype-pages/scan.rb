# PROTOTYPE helper: which elements/classes do the article bodies (between </nav> breadcrumbs and <footer>) actually use?
# ruby pages/_prototype-pages/scan.rb [root]
root = ARGV[0] || "."
skip = %w[index.html calculator.html articles.html contact.html donate.html 404.html about.html]
cls = Hash.new { |h, k| h[k] = [] }
tags = Hash.new { |h, k| h[k] = [] }
Dir["#{root}/*.html"].sort.each do |f|
  n = File.basename(f)
  next if skip.include?(n)
  s = File.read(f)
  body = s[/<article.*?<\/article>/m] || s[/<\/nav>.*?<footer/m] || ""
  body.scan(/class="([^"]+)"/).flatten.flat_map(&:split).uniq.each { |c| cls[c] << n }
  body.scan(/<(table|details|blockquote|img|figure|dl|ol|ul|h2|h3|h4|h5|iframe|video|hr|pre|code)\b/).flatten.uniq.each { |t| tags[t] << n }
end
puts "== tags (pages using) =="
tags.sort_by { |_, v| -v.size }.each { |k, v| puts "#{k.ljust(12)} #{v.size}  #{v.size < 8 ? v.join(' ') : ''}" }
puts "== classes (pages using) =="
cls.sort_by { |_, v| -v.size }.each { |k, v| puts "#{k.ljust(28)} #{v.size}  #{v.size < 6 ? v.join(' ') : ''}" }
