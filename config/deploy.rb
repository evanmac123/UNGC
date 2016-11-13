set :stages, %w(preview staging production)
set :default_stage, 'staging'
set :copy_exclude, ['.git']

require 'capistrano/ext/multistage'

after 'god:restart', 'sphinx:restart'
after 'god:restart', 'god:sidekiq:restart'
