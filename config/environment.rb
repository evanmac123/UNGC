# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'liquid'
  config.gem 'money'
  config.gem 'haml'
#  config.gem 'fastercsv'

  config.time_zone = 'UTC'

  config.active_record.observers = :organization_observer, :logo_request_observer
end

ActionView::Base.default_form_builder = FormBuilder

# Application constants
EMAIL_SENDER = "no-reply@unglobalcompact.org"