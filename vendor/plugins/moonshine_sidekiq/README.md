## Moonshine Sidekiq

For deploying [sidekiq](http://sidekiq.org/) with [moonshine](http://github.com/railsmachine/moonshine). It replaces the built-in capistrano management of sidekiq with [god](http://godrb.com/).

### Installation

    # Rails 2
    script/plugin install git://github.com/railsmachine/moonshine_god.git --force
    script/plugin install git://github.com/railsmachine/moonshine_sidekiq.git --force
    # Rails 3
    script/rails plugin install git://github.com/railsmachine/moonshine_god.git --force
    script/rails plugin install git://github.com/railsmachine/moonshine_sidekiq.git --force

Make sure you place custom Sidekiq configuration options into a `config/sidekiq.yml` ([example](https://github.com/mperham/sidekiq/blob/master/examples/config.yml))

Configure as necessary in your moonshine.yml (or stage-specific moonshine yml):

    :sidekiq:
      :workers: 2
      

Next, add the recipe to the manifests in question:

    # app/manifests/application_manifest.rb
    recipe :god
    recipe :sidekiq

Add the `:sidekiq` and `:god` roles to any servers that run sidekiq:

    # config/deploy/production.rb
    server 'myapp.com', :web, :sidekiq, :god, :db, :primary => true

And make sure to remove sidekiq/capistrano related settings from `config/deploy.rb`, such as:

    require 'sidekiq/capistrano'
    set :sidekiq_cmd, "#{bundle_cmd} exec sidekiq"
    set :sidekiqctl_cmd, "#{bundle_cmd} exec sidekiqctl"
    set :sidekiq_timeout, 10
    set :sidekiq_role, :app
    set :sidekiq_pid, "#{current_path}/tmp/pids/sidekiq.pid"
    set :sidekiq_processes, 1

### Managing Sidekiq with God

This plugin also provides the following Capistrano tasks:

    cap god:sidekiq:stop
    cap god:sidekiq:start
    cap god:sidekiq:restart
    cap god:sidekiq:status

We recommend having Sidekiq restart on deploy to reload code changes:

    # config/deploy.rb
    after 'god:restart', 'god:sidekiq:restart'

### Deploying

That's it. Deploy and done!


***
Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
