# raise "Requires Ruby >= 1.9" unless RUBY_VERSION =~ /^1\.9/

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'jackdempsey-acts_as_commentable', :lib => 'acts_as_commentable', :source => "http://gems.github.com"
  config.gem 'thinking-sphinx-099', :lib     => 'thinking_sphinx', :source => "http://gemcutter.org"
  config.gem 'money'
  config.gem 'haml'

  config.time_zone = 'UTC'

  config.active_record.observers = :logo_comment_observer, :comment_observer
  config.action_controller.session_store = :active_record_store
  
  config.load_paths += %W( #{RAILS_ROOT}/app/reports #{RAILS_ROOT}/app/models/search )
end

ActionView::Base.default_form_builder = FormBuilder
ActiveRecord::Base.colorize_logging = false
ThinkingSphinx.suppress_delta_output = true

# Application constants
EMAIL_SENDER = "no-reply@unglobalcompact.org"