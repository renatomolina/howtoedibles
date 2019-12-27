require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Howtoedibles
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Compressing files
    config.middleware.use Rack::Deflater

    config.autoload_paths += %w(#{config.root}/app/models/ckeditor)
    config.filter_parameters << :password

    unless Rails.env.development?
      Raven.configure do |config|
        config.dsn = 'https://e7b972887d144366944c9cebc5b33017:97693379b36e45b690fde7998ad30da7@sentry.io/185276'
      end
    end

    config.action_view.automatically_disable_submit_tag = false
    config.i18n.available_locales = [:en, :'pt-BR']
    config.i18n.default_locale = :en
  end
end
