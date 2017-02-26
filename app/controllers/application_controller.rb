class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_translations

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end
end
