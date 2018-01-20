class RecipesController < ApplicationController
  before_action :load_categories

  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug]) || Recipe.first
    @suggested_weed = @suggested_portion = nil
  end

  def index
    @recipes = Recipe.all.shuffle
    @suggested_portion = '20'
    @suggested_weed = '3'
  end

  private

  def load_categories
    @categories = Category.all
  end
end
