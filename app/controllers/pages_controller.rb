class PagesController < ApplicationController
  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug] || 'butter')
    @recipes = Recipe.all.order(id: :asc)
  end
end
