source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails', '4.2.4'

# Assets managment
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'autoprefixer-rails'

source 'https://rails-assets.org' do
  gem 'rails-assets-foundation'
  gem 'rails-assets-underscore'
  gem 'rails-assets-backbone'
end

# Templating
gem 'slim-rails'
gem 'simple_form'

# Active record
gem 'pg'
gem 'acts_as_tree'

# User management
gem 'devise'
gem 'cancancan', '~> 1.10'

# API
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'raddocs'

# Server
gem 'dotenv-rails'
gem 'puma'
gem 'rails_12factor', group: :production

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
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'email_spec'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: nil
end
