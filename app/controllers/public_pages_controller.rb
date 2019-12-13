class PublicPagesController < ApplicationController
  layout 'layouts/application_mobile'

  def calculator; end

  def show
    render template: "public_pages/#{template_name}", layout: 'application'
  end

  private

  def template_name
    @template_name ||= params[:public_page]&.tr('-', '_')
  end
end
