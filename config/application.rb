require File.expand_path('../boot', __FILE__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
GC::Profiler.enable

module Undp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir[Rails.root.join('api', 'app', 'controllers', 'concerns')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'users')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'actors')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'acts')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'localizations')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'categories')]
    config.autoload_paths += Dir[Rails.root.join('app', 'models', 'search')]
    config.included_models = ActiveRecord::Base.descendants.map!(&:name)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Europe/Madrid'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.initialize_on_precompile = true
    config.i18n.available_locales = [:en]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.generators do |g|
      g.test_framework  :rspec
      g.view_specs      false
      g.helper_specs    false
      g.factory_girl    false
      g.template_engine :slim
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
    end
  end
end
