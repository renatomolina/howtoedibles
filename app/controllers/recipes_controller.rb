class RecipesController < ApplicationController
  before_action :load_categories

  def show
    @recipe = Recipe.using(domain_name).find_by(slug: params[:recipe_slug])
    not_found unless @recipe.present?

    @recipe.increment_impressions_count
    @suggested_portion = @recipe.suggested_portion
    @suggested_weed = @recipe.suggested_weed
  end

  def index
    @recipes = Recipe.using(domain_name).all.order(impressions_count: :desc)
    @suggested_portion = 50
    @suggested_weed = 4
  end

  private

  def load_categories
    @categories = Category.using(domain_name).all
  end
end
