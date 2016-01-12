Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static file server for tests with Cache-Control for performance.
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
  
  if ENV['BULLET'] == 'enabled'
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.raise = true
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Category', association: :children
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'SocioCulturalDomain', association: :children
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'OtherDomain', association: :children
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Localization', association: :user
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Localization', association: :act_localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Localization', association: :actor_localization
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Localization', association: :indicator_localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActorMacro', association: :localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActorMeso', association: :localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActorMicro', association: :localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActMacro', association: :localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActMeso', association: :localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActMicro', association: :localizations
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActorLocalization', association: :localization
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActLocalization', association: :localization
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'IndicatorLocalization', association: :localization
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActorRelation', association: :relation_type
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActRelation', association: :relation_type
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Measurement', association: :unit
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActActorRelation', association: :relation_type
    end
  end

  config.after_initialize do
    # Set Time.now to September 1, 2015 12:00:00 AM (at this instant)
    t = Time.local(2015, 9, 1, 12, 0, 0, 0)
    Timecop.travel(t)
  end

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 5000 }
  config.action_mailer.delivery_method = :test
end
