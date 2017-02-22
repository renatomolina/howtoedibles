class PagesController < ApplicationController
  def show
    @recipe = Recipe.find_by(slug: params[:recipe_slug] || 'butter')
    @recipes = Recipe.all.order(id: :asc)
  end

  def letsencrypt
    render text: "Z_4HIj9EStV10OGJ0AO7bJlMWsHZjP00UEoeiWbjw9k.f-n6sTIxXlpsOIjhXoBfmQvGW_-1-M7GkwWnrm_gv_E"
  end
end
