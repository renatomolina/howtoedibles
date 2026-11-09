# PROTOTYPE helper: replace a prototype's inline `const T = { … };` table with one built from strings.js.
# Usage: ruby _prototype-strings/swap.rb <prototype index.html> <map file>   (map file = JS object literal body)
file, map = ARGV
html = File.read(file)
start = html.index("const T = {") or abort "no T table in #{file}"
stop = html.index("\n};", start) or abort "no end of T in #{file}"
html[start...(stop + 3)] = "const T = T5({\n#{File.read(map).strip}\n});"
# load strings.js before the prototype's own script (path relative to the prototype)
depth = file.sub(%r{^.*?/strings/}, "").count("/")
html.sub!(/<script>(?!.*<script>)/m, %(<script src="#{"../" * depth}_prototype-strings/strings.js"></script>\n<script>)) unless html.include?("strings.js")
File.write(file, html)
puts "#{file}: T swapped"
