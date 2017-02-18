class PagesController < ApplicationController
  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug] || 'butter')
  end
end
