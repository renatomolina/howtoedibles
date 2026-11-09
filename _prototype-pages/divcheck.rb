# PROTOTYPE helper: article bodies whose <div>s don't balance (the legacy-compat block can't fix broken markup).
# ruby _prototype-pages/divcheck.rb <site root>
root = ARGV[0] || "."
skip = %w[index.html calculator.html articles.html contact.html donate.html 404.html about.html]
Dir["#{root}/{,pt/,es/,de/,zh/}*.html"].sort.each do |f|
  next if skip.include?(File.basename(f))
  body = File.read(f)[/<article.*?<\/article>/m] or next
  o, c = body.scan(/<div\b/).size, body.scan(/<\/div>/).size
  puts "#{f.sub(root + '/', '')}: #{o} open / #{c} close" if o != c
end
