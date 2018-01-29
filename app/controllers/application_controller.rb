class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_translations

  around_action :select_shard
  before_action :set_locale
  before_action :set_raven_context

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def select_shard(&block)
    begin
      domain = request.domain.to_s
      db_config = Rails.application.config.database_configuration
      if domain["laricando"]
        Octopus.using(:laricando, &block)
      else
        Octopus.using(:howtoedibles, &block)
      end
    rescue => exp
      begin
          ActiveRecord::Base.connection.reconnect!
        rescue
          sleep 10
          retry
        else
          retry
        end
      ensure
      if domain["laricando"]
        Octopus.using(:laricando, &block)
      else
        Octopus.using(:howtoedibles, &block)
      end
    end
  end

  def set_locale
    domain = request.domain.to_s
    I18n.locale = domain["laricando"] ? 'pt-BR' : 'en'
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
