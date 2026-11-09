# PROTOTYPE: rebuild every prototype's T table from its map (after a map edit). T is a one-liner call now, so replace it in place.
root = File.join(__dir__, "..")
{ "recipe-final" => "recipes/_prototype-recipe-final", "homepage" => "recipes/_prototype-homepage", "pages" => "_prototype-pages", "navigation" => "recipes/_prototype-navigation" }.each do |m, dir|
  f = File.join(root, dir, "index.html"); h = File.read(f)
  h.sub!(/const T = T5\(\{\n.*?\n\}\);/m, "const T = T5({\n#{File.read(File.join(__dir__, "maps", "#{m}.js")).strip}\n});") or abort "no T5 in #{dir}"
  File.write(f, h)
end
puts "ok"
