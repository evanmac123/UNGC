source 'https://rubygems.org'

ruby "2.3.3"

gem 'rails', '4.2.10'

gem 'pg', '< 1'
gem 'mysql2' # Required for Thinking Sphinx!!!

gem 'facets',               '~> 3.1.0', require: false
gem 'hpricot',              '0.8.6'
gem 'will_paginate'
gem 'paperclip',            '< 6'
gem 'haml',                 '~> 4.0.6'
gem 'acts_as_commentable',  '~> 4.0.2'
gem 'money-rails',          '~> 1.9'
gem 'spreadsheet'
gem 'thinking-sphinx'
gem 'state_machine',                    git: 'https://github.com/seuros/state_machine.git', branch: 'master'
gem 'acts_as_tree'
gem 'annotate',             '~> 2.7.1'
gem 'custom_error_message',             git: 'https://github.com/jeremydurham/custom-err-msg.git', branch: 'master'
gem 'devise',               '~> 3.5.4'
gem 'doorkeeper',            '~> 4.4.0'
gem 'dynamic_form',         '~> 1.1.4'
gem 'honeybadger'
gem 'restforce',            '~> 3.0.0'
gem 'faye'
gem 'roo',                  '~> 2.7.0'

gem 'sass-rails'
gem 'coffee-rails',         '~> 4.2.0'
gem 'jquery-rjs',                       git: 'https://github.com/amatsuda/jquery-rjs.git', branch: 'master'
gem 'jquery-rails',         '~> 4.0.4'
gem 'jquery-ui-rails'
gem 'ckeditor'
gem 'redis-rails'
gem 'sidekiq', '< 6'
gem 'uglifier'
gem 'foreman'
gem 'bourbon',              '~> 4.2.1'
gem 'font-awesome-sass'
gem 'virtus',               '~> 1.0.5'

gem 'capistrano',           '~> 2.15.9'
gem 'plugger' # supports moonshine plugin on rails4
gem 'databasedotcom'
gem 'net-ssh', '~> 4.2'

# for upgrading to rails 4+, need to be removed eventually.
gem 'rails-observers'

gem 'ranked-model',         '~> 0.4.0'
gem 'fog-aws'
gem "non-stupid-digest-assets"
gem 'htmlentities', '~> 4.3', '>= 4.3.4'
gem 'sinatra', :require => nil
gem 'rails_event_store', '~> 0.14.5'
gem 'stripe', '<2'
gem 'saml_idp', '~> 0.7.2'
gem 'faraday'
gem 'faraday-cookie_jar'
gem "cookiejar", :git => "https://github.com/MissionCapital/cookiejar.git"
gem 'awesome_print', require: 'ap'
gem 'bootsnap', require: false
gem 'with_advisory_lock', '~> 3.2'

group :development do
  gem 'thin'
  gem 'bullet'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'web-console'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rake'
end

group :test do
  gem "minitest-rails-capybara"
  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'shoulda'
  gem 'capybara'
  gem 'simplecov', require: false
  gem 'mocha'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'test_after_commit', '~> 1.1'
  gem 'poltergeist'
  gem 'fake_stripe', require: false
  gem 'ruby-saml'
  gem 'spy'
end

group :development, :test do
  gem 'minitest'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'quiet_assets'
  gem 'byebug'
  gem 'spring'
  gem 'guard-spring'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails'
end

group :production do
  gem 'scout'
  gem 'passenger',        '5.3.4'
end
