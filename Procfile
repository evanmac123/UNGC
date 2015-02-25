web: bundle exec rails server -p $PORT
worker: bundle exec rerun --background --dir app/workers/,app/reports --pattern '{**/*.rb}' -- bundle exec sidekiq --verbose
