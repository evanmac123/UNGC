require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'coverband'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(*Rails.groups)

module UNGC
  class Application < Rails::Application
    EMAIL_SENDER = "info@unglobalcompact.org"

    # don't attempt to auto-require the moonshine manifests into the rails env
    config.paths['app/manifests'] = 'app/manifests'
    config.paths['app/manifests'].skip_eager_load!

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    require 'ungc/layout'

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Disable IP Spoof check
    config.action_dispatch.ip_spoofing_check = false

    # http://stackoverflow.com/a/20381730
    config.i18n.enforce_available_locales = true

    # Activate observers that should always be running.
    config.active_record.observers = :logo_comment_observer, :comment_observer

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # load coverband middleware
    config.middleware.use Coverband::Middleware
  end
end
