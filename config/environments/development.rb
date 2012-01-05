# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# cache saves files to tmp/cache
config.cache_store = :file_store, File.join(RAILS_ROOT, "tmp/cache")

# Don't care if the mailer can't send
config.action_mailer.perform_deliveries = false
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_url_options = { :protocal => 'http', :host => '127.0.0.1', :port => 3000 }
config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 1025,
  :domain => "www.unglobalcompact.org"
}
