# raise "Requires Ruby >= 1.9" unless RUBY_VERSION =~ /^1\.9/

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com'
  config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
  config.gem 'jackdempsey-acts_as_commentable', :lib => 'acts_as_commentable', :source => "http://gems.github.com"
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '1.3.14'
  config.gem 'spreadsheet', :version => '0.6.5.7', :lib => nil

  config.gem 'money'
  config.gem 'haml'
  config.gem 'hoptoad_notifier'
  config.time_zone = 'UTC'

  config.active_record.observers = :logo_comment_observer, :comment_observer
  config.action_controller.session_store = :active_record_store
  
  config.load_paths += %W( #{RAILS_ROOT}/app/reports #{RAILS_ROOT}/app/models/search #{RAILS_ROOT}/app/builders)
end

#ActiveRecord::Base.colorize_logging = false

begin
  ThinkingSphinx.suppress_delta_output = true
rescue Exception => e
  puts " ** ERROR: Unable to configure Sphinx; is it installed? Run rake gems to find out."
end

# Application constants
EMAIL_SENDER = "info@unglobalcompact.org"

# EMAIL_SENDER = "United Nations Global Compact <info@unglobalcompact.org>"
# Setting the sender name requires this patch: 
# http://github.com/rails/rails/commit/7e0aa35c20f06fd9ef245155e30e81cfb38bad05
