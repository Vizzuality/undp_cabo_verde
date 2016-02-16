source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails', '4.2.4'
gem 'pg'

# Assets managment
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-sass-rails'
gem 'chosen-rails'
gem 'autoprefixer-rails'
gem 'handlebars_assets'
gem 'i18n-js', '>= 3.0.0.rc11'
gem 'gon'

source 'https://rails-assets.org' do
  gem 'rails-assets-foundation'
  gem 'rails-assets-underscore'
  gem 'rails-assets-backbone'
  gem 'rails-assets-handlebars'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-d3'
end

# Templating
gem 'slim-rails'
gem 'simple_form'
gem 'country_select'
gem 'kaminari'

gem 'acts_as_tree'
gem 'acts-as-taggable-on'
gem 'select2-rails'

# User management
gem 'devise'
gem 'cancancan', '~> 1.10'

# Currency
gem 'money-rails'

# API
gemspec path: 'api'
gem 'responders', '~> 2.0'
gem 'active_model_serializers', '~> 0.8.1'
gem 'oj'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'raddocs'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'teaspoon-mocha'
  gem 'rspec_api_documentation'
  gem 'bullet'
  gem 'rubocop', require: false
end

group :development do
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
end

group :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'email_spec'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
end

# Data seed
gem 'seed-fu'
gem 'faker'

# Monitoring
gem 'newrelic_rpm'

# Server
gem 'dotenv-rails'
gem 'dalli'
gem 'puma'
gem 'rails_12factor', group: :production
