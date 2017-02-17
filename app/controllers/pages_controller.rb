class PagesController < ApplicationController
  def show
    @recipe = Recipe.find_by(name: 'Butter')
  end
end
