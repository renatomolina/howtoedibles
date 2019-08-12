class PublicPagesController < ApplicationController
  layout 'layouts/application_mobile'

  def calculator; end

  def about
    render layout: 'application'
  end
end
