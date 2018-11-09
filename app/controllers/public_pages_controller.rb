class PublicPagesController < ApplicationController
  def calculator
    @recipes = Recipe.take(4)
  end

  private

  def template_name
    @template_name ||= params[:public_page]&.tr('-', '_')
  end
end
