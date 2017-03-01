module PagesHelper
  def tab_highlight?(recipe_slug, recipe)
    'active' if recipe_slug == recipe.slug || recipe_slug.nil? && recipe.slug == t(:first_recipe)
  end
end
