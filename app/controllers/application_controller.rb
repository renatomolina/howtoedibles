class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_translations

  before_action :set_locale
  before_action :set_raven_context

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def set_locale
    I18n.locale = ENV["APP_ENV"] == "laricando" ? 'pt-BR' : 'en'
  end

  # Sentry
  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
