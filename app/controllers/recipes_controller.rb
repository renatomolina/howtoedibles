class RecipesController < ApplicationController
  def show
    category = Category.friendly.find(params[:category_slug] || params[:category_id])
    @recipe = category.recipes.friendly.find(params[:recipe_slug] || params[:id])
    @suggested_portion = @recipe.suggested_portion
    @suggested_weed = @recipe.suggested_weed
  end

  def index
    @recipes = Recipe.all.includes(:category)
    @suggested_portion = 50
    @suggested_weed = 4
  end
end
