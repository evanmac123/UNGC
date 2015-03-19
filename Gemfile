source 'https://rubygems.org'

gem 'rails', '4.2.1'

gem 'redis-session-store'
gem 'mysql2',               '~> 0.3.17'
gem 'facets',               '~> 3.0.0', require: false
gem 'hpricot',              '0.8.6'
gem 'will_paginate',        '~> 3.0.7'
gem 'paperclip',            '~> 4.2.1'
gem 'haml',                 '~> 4.0.6'
gem 'acts_as_commentable',  '~> 4.0.2'
gem 'money',                '~> 2.1.5'
gem 'newrelic_rpm',         '~> 3.9.9.275'
gem 'spreadsheet',          '0.6.5.9'
gem 'thinking-sphinx',      '~> 3.1.3'
gem 'state_machine',                    github: 'seuros/state_machine', ref: 'master'
gem 'acts_as_tree',         '~> 2.0.0'
gem 'annotate',             '~> 2.5.0'
gem 'fixture_replacement',              github: 'smtlaissezfaire/fixturereplacement', ref: 'master'
gem 'custom_error_message',             github: 'jeremydurham/custom-err-msg', ref: 'master'
gem 'airbrake',             '~> 4.1.0'
gem 'devise',               '~> 3.4.1'
gem 'dynamic_form',         '~> 1.1.4'
gem 'skylight'

gem 'sass-rails',           '~> 5.0'
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

gem 'capistrano',           '~> 2.15.5'
gem 'plugger' # supports moonshine plugin on rails4
gem 'databasedotcom'

# for upgrading to rails 4+, need to be removed eventually.
gem 'rails-observers'

gem 'ranked-model',         '~> 0.4.0'

group :development do
  gem 'rerun'
  gem 'thin'
end

group :test do
  gem 'minitest'
  gem 'shoulda'
  gem 'capybara'
  gem 'simplecov', require: false
  gem 'mocha', '~> 1.1.0'
end

group :development, :test do
  gem 'awesome_print', require: 'ap'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :production do
  gem 'scout',            '5.9.8'
  gem 'passenger',        '~> 4.0.57'
end
