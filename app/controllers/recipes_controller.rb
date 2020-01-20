class RecipesController < ApplicationController
  def show
    load_recipe
    load_suggested_portion
    load_suggested_potency
    load_suggested_quantity
  end

  def index
    @recipes = Recipe.all.order(position: :asc).includes(:category).paginate(page: params[:page], per_page: 9)
    @suggested_portion = Recipe::DEFAULT_PORTION
    @suggested_quantity = Recipe::DEFAULT_QUANTITY
    @suggested_potency = Recipe::DEFAULT_POTENCY
  end

  private

  def load_recipe
    category = Category.friendly.find(params[:category_slug] || params[:category_id])
    @recipe = category.recipes.friendly.find(params[:recipe_slug] || params[:id])
  end

  def load_suggested_portion
    @suggested_portion = params[:portion] || @recipe.suggested_portion
  end

  def load_suggested_quantity
    @suggested_quantity = params[:quantity] || @recipe.suggested_quantity
  end

  def load_suggested_potency
    @suggested_potency = params[:potency] || Recipe::DEFAULT_POTENCY
  end
end
