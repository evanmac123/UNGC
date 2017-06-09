source 'https://rubygems.org'

ruby "2.3.3"

gem 'rails', '4.2.7.1'

gem 'mysql2',               '~> 0.3.17'
gem 'facets',               '~> 3.0.0', require: false
gem 'hpricot',              '0.8.6'
gem 'will_paginate',        '~> 3.0.7'
gem 'paperclip',            '~> 4.3.6'
gem 'haml',                 '~> 4.0.6'
gem 'acts_as_commentable',  '~> 4.0.2'
gem 'money-rails',          '~> 1.8'
gem 'spreadsheet',          '0.6.5.9'
gem 'thinking-sphinx',      '~> 3.2.0'
gem 'state_machine',                    git: 'https://github.com/seuros/state_machine.git', branch: 'master'
gem 'acts_as_tree',         '~> 2.0.0'
gem 'annotate',             '~> 2.7.1'
gem 'custom_error_message',             git: 'https://github.com/jeremydurham/custom-err-msg.git', branch: 'master'
gem 'devise',               '~> 3.5.4'
gem 'doorkeeper'
gem 'dynamic_form',         '~> 1.1.4'
gem 'honeybadger', '~> 2.0'
gem 'restforce'
gem 'faye'

gem 'sass-rails',           '~> 5.0.6'
gem 'coffee-rails',         '~> 4.1.0'
gem 'jquery-rjs',                       git: 'https://github.com/amatsuda/jquery-rjs.git', branch: 'master'
gem 'jquery-rails',         '~> 4.0.4'
gem 'jquery-ui-rails'
gem 'uglifier',             '~> 2.7.2'
gem 'ckeditor',             '4.1.1'
gem 'sidekiq',              '~> 3.4.2'
gem 'foreman'
gem 'bourbon',              '~> 4.2.1'
gem 'font-awesome-sass',    '~> 4.3.1'
gem 'virtus',               '~> 1.0.5'

gem 'capistrano',           '~> 2.15.5'
gem 'plugger' # supports moonshine plugin on rails4
gem 'databasedotcom'
gem 'net-ssh', '~> 4.0'

# for upgrading to rails 4+, need to be removed eventually.
gem 'rails-observers'

gem 'ranked-model',         '~> 0.4.0'
gem 'fog',                  '~> 1.38'
gem "non-stupid-digest-assets"
gem 'htmlentities', '~> 4.3', '>= 4.3.4'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'rack-request_replication', git: 'https://github.com/bitfield-co/rack-request_replication.git', branch: 'master'
gem 'rails_event_store', '~> 0.14.3'
gem 'saml_idp'
gem 'faraday'
gem 'faraday-cookie_jar'

group :development do
  gem 'rerun'
  gem 'thin'
  gem 'bullet'
  gem 'brakeman', '~> 3.4', '>= 3.4.1'
  gem 'bundler-audit', '~> 0.5.0'
  gem 'web-console', '~> 2.1.3'
end

group :test do
  gem 'minitest'
  gem 'shoulda'
  gem 'capybara'
  gem 'simplecov', require: false
  gem 'mocha', '~> 1.1.0'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'ruby-saml'
end

group :development, :test do
  gem 'awesome_print', require: 'ap'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'byebug'
  gem 'spring'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'dotenv-rails'
end

group :production do
  gem 'scout',            '5.9.8'
  gem 'passenger',        '~> 4.0.60'
end
