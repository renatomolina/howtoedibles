class RecipesController < ApplicationController
  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug]) || Recipe.first
    @recipes = Recipe.all.order(id: :asc)
  end
end
