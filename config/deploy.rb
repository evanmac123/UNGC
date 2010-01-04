set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :deploy_to, "/srv/unglobalcompact"

# Use Git source control
set :scm, :git
set :repository, "git@github.com:unspace/UNGC.git"
# Deploy from master branch by default
set :branch, "master"
set :deploy_via, :remote_cache
set :scm_verbose, true

set :user, 'rails'

namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    # run "touch #{current_path}/tmp/restart.txt"
    sudo "/etc/init.d/apache2 restart"
  end
end

after 'deploy:update_code', 'files:copy_database_yml'
after 'deploy:update_code', 'files:copy_sphinx_config'
after 'deploy:update_code', 'files:symlink_docs'
after 'files:copy_database_yml', 'deploy:migrate'

# Avoid keeping the database.yml configuration in git.
namespace :files do
  task :copy_database_yml, :roles => :app do
    db_config = "/srv/unglobalcompact/shared/config/database.yml"
    run "cp #{db_config} #{release_path}/config/database.yml"
  end
  
  task :copy_sphinx_config, :roles => :app do
    db_config = "/srv/unglobalcompact/shared/config/production.sphinx.conf"
    run "ln -s #{db_config} #{release_path}/config/production.sphinx.conf"
  end
  
  task :symlink_docs, :roles => :app do
    run "ln -s /srv/unglobalcompact/shared/docs #{release_path}/public/docs"
  end
end