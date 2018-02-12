namespace :db do

  desc "re-create the database from target_date's production snapshot. Usage: rake db:reset_from_snapshot[2016-02-23] or omit the date for yesterday's snapshot"
  task :reset_from_snapshot, [:date] => :environment do |task, args|
    raise "Must be NOT be run from the production environment" if Rails.env.production?

    date = args[:date]&.gsub("-", "_")
    snapshot = Snapshot::ResetFromSnapshot.new(
      date: date,
      database_config: Rails.configuration.database_configuration[Rails.env])

    snapshot.fetch_from_remote_host
    snapshot.restore_into_database
  end

end
