class PublicPagesController < ApplicationController
  layout 'layouts/application_mobile'

  def calculator; end

  def show
    raise ActionController::RoutingError.new('Not Found') unless pages_allowed.include?(template_name)
    render template: "public_pages/#{template_name}", layout: 'application'
  end

  private

  def template_name
    @template_name ||= params[:public_page]&.tr('-', '_')
  end

  def pages_allowed
    ['about', 'calculator', 'hiring']
  end
end
