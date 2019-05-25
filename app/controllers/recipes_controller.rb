class RecipesController < ApplicationController
  def show
    category = Category.friendly.find(params[:category_slug] || params[:category_id])
    @recipe = category.recipes.friendly.find(params[:recipe_slug] || params[:id])
    @suggested_portion = params[:portion] || @recipe.suggested_portion
    @suggested_quantity = params[:quantity] || @recipe.suggested_quantity
    @suggested_potency = params[:potency] || 14
  end

  def index
    @recipes = Recipe.all.order(position: :asc).includes(:category)
    @suggested_portion = 50
    @suggested_quantity = 4
    @suggested_potency = 14
  end
end
