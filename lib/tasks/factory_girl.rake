# lib/tasks/factory_bot.rake
# Adapted from https://github.com/thoughtbot/factory_bot/issues/772
namespace :factory_bot do
  desc 'Verify that FactoryBot factories are valid'
  task :lint, [:path] => :environment do |t|
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        FactoryBot.lint
      ensure
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
    end
  end
end