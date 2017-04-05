class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_translations

  around_filter :select_shard

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def select_shard(&block)
    domain = request.domain.to_s
    domain["laricando"] ? Octopus.using(:laricando, &block) : Octopus.using(:howtoedibles, &block)
  end
end
