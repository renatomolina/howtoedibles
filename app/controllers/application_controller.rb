class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_translations

  around_filter :select_shard
  before_action :set_locale

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def select_shard(&block)
    domain = request.domain.to_s
    db_config = Rails.application.config.database_configuration
    if domain["laricando"]
      Recipe.establish_connection(db_config['laricando'])
    else
      Recipe.establish_connection(db_config['production'])
    end
  end

  def set_locale
    domain = request.domain.to_s
    I18n.locale = domain["laricando"] ? 'pt-BR' : 'en'
  end
end
