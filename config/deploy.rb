set :stages, %w(staging production)
set :default_stage, 'staging'

require 'capistrano/ext/multistage'

after 'god:restart', 'sphinx:restart'
