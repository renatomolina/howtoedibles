# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.howtoedibles.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  Recipe.find_each do |recipe|
    add category_recipe_path(recipe.category, recipe.slug), :lastmod => recipe.updated_at
  end
end

SitemapGenerator::Sitemap.create_index = true
