require "fileutils"
require "open-uri"

DEST_DIR = Rails.root.join("static-site", "images", "recipes")
STATIC_DIR = Rails.root.join("static-site", "images")
ASSETS_DIR = Rails.root.join("app", "assets", "images")

FileUtils.mkdir_p(DEST_DIR)
FileUtils.mkdir_p(STATIC_DIR)

# Copy static assets from app/assets/images/
STATIC_ASSETS = %w[
  howtoedibleslogo.png
  howtoedibleslogobigger.png
  howtoediblessmalllogo.png
  pot-brownies.jpg
  potency_formula.png
  missing_recipe.jpg
  favicon_385_icon.ico
]

STATIC_ASSETS.each do |filename|
  src = ASSETS_DIR.join(filename)
  dst = STATIC_DIR.join(filename)
  if File.exist?(src)
    FileUtils.cp(src, dst)
    puts "Copied: #{filename}"
  else
    puts "MISSING (skipped): #{filename}"
  end
end

# Copy favicon to static-site root
favicon_src = ASSETS_DIR.join("favicon_385_icon.ico")
favicon_dst = Rails.root.join("static-site", "favicon_385_icon.ico")
FileUtils.cp(favicon_src, favicon_dst) if File.exist?(favicon_src)

# Download recipe photos from S3
recipes = Recipe.published.order(:position).includes(:category)
puts "\nDownloading #{recipes.count} recipe photos..."

recipes.each do |recipe|
  slug = recipe.slug
  dest_path = DEST_DIR.join("#{slug}.jpg")

  if File.exist?(dest_path)
    puts "  SKIP (exists): #{slug}.jpg"
    next
  end

  begin
    url = recipe.photo.url
    if url.blank? || url.include?("missing")
      puts "  MISSING photo: #{slug}"
      # Copy missing_recipe.jpg as fallback
      fallback = ASSETS_DIR.join("missing_recipe.jpg")
      FileUtils.cp(fallback, dest_path) if File.exist?(fallback)
      next
    end

    puts "  Downloading: #{slug}.jpg from #{url[0..60]}..."
    URI.open(url) do |remote|
      File.open(dest_path, "wb") { |f| f.write(remote.read) }
    end
    puts "    OK: #{dest_path}"
  rescue => e
    puts "  ERROR downloading #{slug}: #{e.message}"
  end
end

puts "\nDone! Recipe images in: #{DEST_DIR}"
puts "Static assets in: #{STATIC_DIR}"
