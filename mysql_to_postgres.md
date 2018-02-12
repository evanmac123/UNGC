# Migrate from MySQL to PostgreSQL

1. Checkout the migration branch
2. Configure database.yml for postgres
3. $ bundle exec rake db:drop db:create db:schema:load
4. Update convert-database to reflect the correction connection string for production MySQL and PostgreSQL
5. $ pgloader --verbose convert-database
6. $ bundle exec rake postgres:install_extentions
7. $ bundle exec rake postgres:install_extentions
8. $ bundle exec rake search:rebuild
