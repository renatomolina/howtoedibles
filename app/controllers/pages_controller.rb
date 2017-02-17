class PagesController < ApplicationController

  def show
    @recipe = Recipe.find_by(name: params[:recipe_name]&.capitalize || 'Butter')
  end
end
