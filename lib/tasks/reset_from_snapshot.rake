require 'net/scp'

namespace :db do
  desc "re-create the database from target_date's production snapshot. Usage: rake db:reset_from_snapshot[2016-02-23] or omit the date for yesterday's snapshot"
  task :reset_from_snapshot, [:date] => :environment do |task, args|
    raise "Must be NOT be run from the production environment" if Rails.env.production?
    host = 'unglobalcompact.org'

    target_date = if date_str = args[:date]
                    date_str.gsub('-', '_')
                  else
                    1.day.ago.strftime('%Y_%m_%d')
                  end

    snapshot = "production_unglobalcompact_#{target_date}.sql"
    server_path = "/home/rails/ungc/mysql_dumps/#{snapshot}.gz"
    extra_tables_server_path = "/home/rails/ungc/mysql_dumps/sessions_and_searchables_tables.sql.gz"
    snapshot_dir = "./tmp/snapshots"
    snapshot_path = "#{snapshot_dir}/#{snapshot}"
    zipped_path = "#{snapshot_path}.gz"
    extra_tables_path = "#{snapshot_dir}/sessions_and_searchables_tables.sql.gz"
    unzipped_sessions_and_searchables_tables_path = "#{snapshot_dir}/sessions_and_searchables_tables.sql"
    zipped_sessions_and_searchables_tables_path = "#{unzipped_sessions_and_searchables_tables_path}.gz"

    FileUtils.mkdir_p snapshot_dir
    unless File.exist? snapshot_path
      puts "Removing old snapshots"
      puts FileUtils.rm Dir.glob("#{snapshot_dir}/*.sql"), force: true

      Net::SCP.start("unglobalcompact.org", "rails") do |scp|
        scp.download!(server_path, zipped_path) do |ch, name, sent, total|
          $stdout.write sprintf("\rGetting the #{target_date} mysql production snapshot... %.1f%", (sent.to_f/total.to_f * 100))
          $stdout.flush
        end
      end

      system "gunzip #{zipped_path}"
    end

    begin
      Net::SCP.start("unglobalcompact.org", "rails") do |scp|
        scp.download!(extra_tables_server_path, zipped_sessions_and_searchables_tables_path) do |ch, name, sent, total|
          $stdout.write sprintf("\rGetting the extra table definitions... %.1f%", (sent.to_f/total.to_f * 100))
          $stdout.flush
        end
      end
    rescue
      puts "Failed to get extra table definitions"
    end

    if File.exist? zipped_sessions_and_searchables_tables_path
      FileUtils.rm unzipped_sessions_and_searchables_tables_path
      system "gunzip #{zipped_sessions_and_searchables_tables_path}"
    end

    puts "\nRecreating the database from schema"
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    # Rake::Task["db:schema:load"].invoke

    # puts "Emptying schema_migrations table"
    # conn = ActiveRecord::Base.connection
    # tables = conn.execute("show tables").map { |r| r[0] }
    # tables.delete "schema_migrations"

    puts "Seeding the database from the snapshot"
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    cmd = ['mysql', '-D', database]
    cmd << "-u#{username}" if username.present?
    cmd << "-p#{password}" if password.present?
    cmd << "< #{snapshot_path}"
    system cmd.join(" ")

    puts "Appending the sessions and searchables tables"
    cmd = ['mysql', '-D', database]
    cmd << "-u#{username}" if username.present?
    cmd << "-p#{password}" if password.present?
    cmd << "< #{unzipped_sessions_and_searchables_tables_path}"
    system cmd.join(" ")

    Rake::Task["db:migrate:status"].invoke

    puts "Migrating development and test environments"
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:test:prepare"].invoke
    Rake::Task["db:create_dummy_accounts"].invoke
  end

  desc "create dummy accounts for non-production environments"
  task create_dummy_accounts: [:environment] do
    DummyAccounts.create unless Rails.env.production?
  end

end
