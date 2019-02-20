Rails.application.configure do
  class MissingRequiredConfiguration < StandardError
    def initialize(env_var)
      @env_var = env_var
    end

    def env_var
      @env_var
    end

    def message
      "Missing required environment variable: #{env_var}"
    end
  end

  def print_message(message)
    puts "*" * message.size
    puts message
    puts "*" * message.size
  end

  def get_env(env_var)
    ENV[env_var] or (ENV['ASTERISK_MONITOR_IGNORE_CONFIGS'] or raise MissingRequiredConfiguration.new(env_var))
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "os_phone_book_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # use Sendmail by default:
  config.action_mailer.delivery_method = (ENV['MAILER_DELIVERY_METHOD'] || :sendmail).downcase.to_sym

  config_file_path = Rails.root.join 'config/basic_config.yml'
  if File.exists? config_file_path
    config.basic_config = YAML::load_file(config_file_path)
  else
    config.basic_config = {}
  end

  if config.basic_config["mailer"]
    config.action_mailer.smtp_settings = config.basic_config["mailer"]["smtp_settings"]
    config.action_mailer.default_url_options = config.basic_config["mailer"]["default_url_options"]

    if config.basic_config["mailer"]["sender_address"]
      config.basic_config["sender_address"] = config.basic_config["mailer"]["sender_address"]
    end
  end

  if ENV['MAILER_DEFAULT_URI']
    uri = URI(ENV['MAILER_DEFAULT_URI'])
    host = uri.host
    protocol = uri.scheme
    config.action_mailer.default_url_options = {host: host, protocol: protocol}
  end

  config.basic_config["sender_address"] = ENV['MAILER_SENDER_ADDRESS'] if ENV['MAILER_SENDER_ADDRESS']

  env_smtp_config = {}
  env_smtp_config[:address] = ENV['SMTP_ADDRESS'] if ENV['SMTP_ADDRESS']
  env_smtp_config[:domain] = ENV['SMTP_DOMAIN'] if ENV['SMTP_DOMAIN']
  env_smtp_config[:port] = ENV['SMTP_PORT'].to_i if ENV['SMTP_PORT']
  env_smtp_config[:enable_starttls_auto] = !!ENV['SMTP_ENABLE_STARTTLS_AUTO'] if ENV['SMTP_ENABLE_STARTTLS_AUTO']
  env_smtp_config[:user_name] = ENV['SMTP_USERNAME'] if ENV['SMTP_USERNAME']
  if ENV['SMTP_PASSWORD']
    env_smtp_config[:password] = ENV['SMTP_PASSWORD']
    ENV['SMTP_PASSWORD'] = nil
  end

  config.action_mailer.smtp_settings = env_smtp_config if env_smtp_config.size > 0

  if config.action_mailer.smtp_settings.blank?
    print_message "SMTP not configured! Disabling e-mails!"
    config.action_mailer.default_url_options = { :host => "localhost", :port => "3000", :protocol => "http" }
    config.action_mailer.delivery_method = :test
    config.action_mailer.perform_deliveries = false
  else
    config.action_mailer.perform_deliveries = true
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.asterisk_monitor = {
    host: get_env('ASTERISK_MONITOR_HOST'),
    port: get_env('ASTERISK_MONITOR_PORT'),
    username: get_env('ASTERISK_MONITOR_USERNAME'),
    secret: get_env('ASTERISK_MONITOR_SECRET'),
    channel: get_env('ASTERISK_MONITOR_CHANNEL'),
    context: get_env('ASTERISK_MONITOR_CONTEXT'),
    timeout: get_env('ASTERISK_MONITOR_TIMEOUT'),
    priority: get_env('ASTERISK_MONITOR_PRIORITY')
  }
end
