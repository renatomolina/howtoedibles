class RecipesController < ApplicationController
  def show
    @categories = Category.all
    @recipe = Recipe.find_by(slug: params[:recipe_slug]) || Recipe.first
  end
end
