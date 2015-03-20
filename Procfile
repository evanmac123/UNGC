web: bundle exec rails server -p $PORT -b 0.0.0.0
worker: bundle exec rerun --background --dir app/workers/,app/reports --pattern '{**/*.rb}' -- bundle exec sidekiq --verbose
