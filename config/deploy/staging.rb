role :app, "staging.unglobalcompact.railsmachina.com"
role :web, "staging.unglobalcompact.railsmachina.com"
role :db,  "staging.unglobalcompact.railsmachina.com", :primary => true

# We may want to deploy from experimental branches
set :branch do
  requested_branch = Capistrano::CLI.ui.ask('What branch do you want to deploy? ') { |q| q.default = "staging" }
end
