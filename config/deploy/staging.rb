server 'staging.unglobalcompact.org', :web, :app, :db, :god, :sphinx, :primary => true

set :branch do
  requested_branch = Capistrano::CLI.ui.ask('What branch do you want to deploy? ') { |q| q.default = "staging" }
end
