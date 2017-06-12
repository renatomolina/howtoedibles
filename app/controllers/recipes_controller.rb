class RecipesController < ApplicationController
  before_action :load_categories

  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug]) || Recipe.first
  end

  def index
    @recipes = Recipe.all
  end

  private

  def load_categories
    @categories = Category.all
  end
end
