class RecipesController < ApplicationController
  before_action :load_categories

  def show
    @category = Category.find_by(slug: params[:category_id])
    @recipe = Recipe.find_by(slug: params[:id])
    not_found unless @recipe && @category

    @suggested_portion = @recipe.suggested_portion
    @suggested_weed = @recipe.suggested_weed
  end

  def index
    @recipes = Recipe.all
    @suggested_portion = 50
    @suggested_weed = 4
  end

  private

  def load_categories
    @categories = Category.all
  end
end
