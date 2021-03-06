Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Caching.
  if ENV['DEV_CACHE'] == 'enabled'
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = true
    config.cache_store = :dalli_store, '127.0.0.1:11215', {
                                         namespace: Undp,
                                         expires_in: 10.minutes,
                                         compress: true
                                       }
  else
    # Show full error reports and disable caching.
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false
  end
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  if ENV['BULLET'] == 'enabled'
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.raise = true
      Bullet.add_footer = true
      Bullet.alert = true
      Bullet.bullet_logger = true
      Bullet.rails_logger = true
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
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Measurement', association: :unit
      Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ActActorRelation', association: :relation_type
    end
  end
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 5000 }
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: ENV['GMAIL_DOMAIN'],
    authentication: 'plain',
    enable_starttls_auto: true,
    user_name: ENV['GMAIL_USERNAME'],
    password: ENV['GMAIL_PASSWORD']
  }
end
