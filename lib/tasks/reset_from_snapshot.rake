namespace :db do
  desc "re-create the database from yesterday's production snapshot"
  task reset_from_snapshot: ["db:drop", "db:create", "db:schema:load"] do
    raise "Must be run from the development environment" unless Rails.env.development?
    host = 'unglobalcompact.org'
    user = 'rails'

    yesterday = (Date.today - 1.day).strftime('%Y_%m_%d')
    snapshot = "production_unglobalcompact_#{yesterday}.sql"
    server_path = "/home/rails/ungc/mysql_dumps/#{snapshot}.gz"
    snapshot_dir = "./tmp/snapshots"
    snapshot_path = "#{snapshot_dir}/#{snapshot}"
    zipped_path = "#{snapshot_path}.gz"

    FileUtils.mkdir_p snapshot_dir
    unless File.exist? snapshot_path
      puts "Removing old snapshots"
      FileUtils.rm "#{snapshot_dir}/*.sql", force: true

      puts "Getting the latest mysql production snapshot"
      system "scp rails@unglobalcompact.org:#{server_path} #{zipped_path}"

      system "gunzip #{zipped_path}"
    end

    puts "Seeding the database from the snapshot"
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    cmd = ['mysql', '-D', database]

    if username.present?
      cmd << '-u'
      cmd << username
    end

    if password.present?
      cmd << '-p'
      cmd << password
    end

    cmd << '<'
    cmd << snapshot_path

    system cmd.join(" ")

    Rake::Task["db:migrate:status"].invoke

    puts "Migrating development and test environments"
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:test:prepare"].invoke # TODO rails4 db:test:prepare is deprecated
  end
end