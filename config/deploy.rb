set :stages, %w(preview staging production)
set :default_stage, 'staging'

require 'capistrano/ext/multistage'

after 'god:restart', 'sphinx:restart'
after 'god:restart', 'god:sidekiq:restart'
