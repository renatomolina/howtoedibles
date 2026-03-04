module RecipesHelper
  def tab_highlight?(slug, category)
    'active' if slug == category.slug || slug.nil? && category.slug == t(:first_recipe)
  end
end
