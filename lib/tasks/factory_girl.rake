# lib/tasks/factory_girl.rake
# Adapted from https://github.com/thoughtbot/factory_bot/issues/772
namespace :factory_girl do
  desc 'Verify that FactoryGirl factories are valid'
  task :lint, [:path] => :environment do |t|
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        FactoryGirl.lint
      ensure
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
    end
  end
end