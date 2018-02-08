class RecipesController < ApplicationController
  before_action :load_categories

  def show
    @category = Category.find_by(slug: params[:category_slug])
    @recipe = Recipe.find_by(slug: params[:recipe_slug])
    not_found unless @recipe && @category

    @recipe.increment_impressions_count
    @suggested_portion = @recipe.suggested_portion
    @suggested_weed = @recipe.suggested_weed
  end

  def index
    @recipes = Recipe.all.order(impressions_count: :desc)
    @suggested_portion = 50
    @suggested_weed = 4
  end

  private

  def load_categories
    @categories = Category.all
  end
end
