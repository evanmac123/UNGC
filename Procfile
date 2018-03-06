web: bundle exec rails server -p $PORT -b 0.0.0.0
worker: bundle exec sidekiq --verbose
sitemap: /bin/bash -c 'cd frontend/sitemap && ember s -p 4200 --proxy http://127.0.0.1:${PORT}'
