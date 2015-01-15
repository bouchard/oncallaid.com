OnCallAid::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # Assets.
  config.sass.line_comments = false if config.respond_to?(:sass)
  # Precompile *all* assets, except those that start with underscore
  config.assets.precompile = [ /(^[^_\/]|\/[^_])[^\/]*$/ ]
  config.assets.compile = false
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  config.eager_load = true

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # We're always running behind SSL.
  config.force_ssl = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # Asset host disabled because SPDY is awesome!
  # config.action_controller.asset_host = "http://oncallaid.com"

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_files = false

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'oncallaid.com' }
  config.action_mailer.delivery_method = :sendmail

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
