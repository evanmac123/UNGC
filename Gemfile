source 'https://rubygems.org'

gem 'rails', '3.2.8'

gem 'mysql2'
gem 'facets',               '~> 2.9.3', :require => false
gem 'hpricot',              '0.8.4'
gem 'json_pure',            '1.2.0'
gem 'will_paginate',        '~> 3.0.3'
gem 'paperclip',            '~> 2.3.1'
gem 'haml',                 '~> 3.1.7'
gem 'acts_as_commentable',  '~> 3.0.1'
gem 'money',                '~> 2.1.5'
gem 'newrelic_rpm',         '~> 3.4.1'
gem 'spreadsheet',          '0.6.5.9'
gem 'thinking-sphinx',      '~> 2.0.10'
gem 'state_machine',        '~> 1.1.2'
gem 'acts_as_tree_rails3',  '~> 0.1.0'
gem 'annotate',             '~> 2.5.0'
gem 'fixture_replacement',  :git => 'git://github.com/smtlaissezfaire/fixturereplacement.git', :branch => 'master'
gem 'custom_error_message', :git => 'git://github.com/jeremydurham/custom-err-msg.git', :branch => 'master'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  gem 'sqlite3'
  # gem 'after_commit',   '1.0.5' #why is this only set in dev???
  gem 'thin'
end

group :test do
  gem "shoulda",          '~> 3.3.0'
end

group :production do
  gem 'scout',            '5.5.4'
  gem 'airbrake',         '~> 3.1.2'
  gem 'passenger',        '3.0.7'
end

group :development, :test do
  gem 'noexec',         '0.1.0'
end

gem 'capistrano'
