source 'https://rubygems.org'

gem 'rails', '4.2.5.1'

gem 'mysql2',               '~> 0.3.17'
gem 'facets',               '~> 3.0.0', require: false
gem 'hpricot',              '0.8.6'
gem 'will_paginate',        '~> 3.0.7'
gem 'paperclip',            '~> 4.3.6'
gem 'haml',                 '~> 4.0.6'
gem 'acts_as_commentable',  '~> 4.0.2'
gem 'money',                '~> 2.1.5'
gem 'spreadsheet',          '0.6.5.9'
gem 'thinking-sphinx',      '~> 3.2.0'
gem 'state_machine',                    github: 'seuros/state_machine', ref: 'master'
gem 'acts_as_tree',         '~> 2.0.0'
gem 'annotate',             '~> 2.7.1'
gem 'custom_error_message',             github: 'jeremydurham/custom-err-msg', ref: 'master'
gem 'devise',               '~> 3.4.1'
gem 'dynamic_form',         '~> 1.1.4'
gem 'skylight',             '~> 0.10.3'
gem 'honeybadger', '~> 2.0'

gem 'sass-rails',           '5.0.3'
gem 'coffee-rails',         '~> 4.1.0'
gem 'jquery-rjs',                       github: 'amatsuda/jquery-rjs', ref: 'master'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'uglifier',             '~> 2.7.0'
gem 'ckeditor',             '4.1.1'
gem 'sidekiq',              '~> 2.17.0'
gem 'foreman'
gem 'bourbon',              '~> 4.2.1'
gem 'font-awesome-sass',    '~> 4.3.1'
gem 'virtus',               '~> 1.0.5'

gem 'capistrano',           '~> 2.15.5'
gem 'plugger' # supports moonshine plugin on rails4
gem 'databasedotcom'
gem 'net-ssh'

# for upgrading to rails 4+, need to be removed eventually.
gem 'rails-observers'

gem 'ranked-model',         '~> 0.4.0'
gem 'fog'
gem "non-stupid-digest-assets"
gem 'htmlentities'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'rack-request_replication', :github => 'bitfield-co/rack-request_replication', :branch => 'master'

group :development do
  gem 'faraday'
  gem 'rerun'
  gem 'thin'
  gem 'bullet'
end

group :test do
  gem 'minitest'
  gem 'shoulda'
  gem 'capybara'
  gem 'simplecov', require: false
  gem 'mocha', '~> 1.1.0'
  gem 'database_cleaner'
  gem 'webmock'
end

group :development, :test do
  gem 'awesome_print', require: 'ap'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'dotenv-rails'
end

group :production do
  gem 'scout',            '5.9.8'
  gem 'passenger',        '~> 4.0.57'
end
