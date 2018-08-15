source 'https://rubygems.org'

ruby '2.4.4'

gem 'rails', '~> 5.2.0'
gem 'pg', '~> 0.21.0'
gem 'puma', '~> 3.0'
gem 'therubyracer', platforms: :ruby
gem 'jbuilder', '~> 2.5'
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'

gem 'newrelic_rpm'
gem 'sitemap_generator'
gem 'rails-i18n', '~> 5.0.0'
gem 'rack-cors', :require => 'rack/cors'
gem 'friendly_id', '~> 5.2.0'
gem "paperclip", "~> 5.0.0"
gem 'aws-sdk', '~> 2.5.11'
gem 'sentry-raven'

# Assets
gem 'jquery-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'ckeditor', github: 'galetahub/ckeditor'
gem 'font-awesome-rails'

# increase server memory consumption
gem 'puma_worker_killer'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.7'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 3.1', require: false
  gem 'database_cleaner', '~> 1.7'
  gem 'faker'
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard-rspec', require: false
  gem 'guard-shell', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
