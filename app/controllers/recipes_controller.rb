class RecipesController < ApplicationController
  before_action :load_categories

  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug])
    @recipe.increment_impressions_count
    @suggested_portion = @recipe.suggested_portion
    @suggested_weed = @recipe.suggested_weed
  end

  def index
    @recipes = Recipe.all.order(impressions_count: :desc)
    @suggested_portion = 15
    @suggested_weed = 1.5
  end

  private

  def load_categories
    @categories = Category.select(:name).all
  end
end
