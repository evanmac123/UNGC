module Snapshot
  class ResetFromSnapshot
    attr_accessor :snapshot_path, :extras_path

    def initialize(date:, database_config:)
      @date = date || 1.day.ago.strftime("%Y_%m_%d")
      @strategy = choose_strategy(database_config)
      @downloader = Downloader.new(@strategy.ssh_host, "rails")

      @local_dir = @strategy.local_dir
      @remote_dir = @strategy.remote_dir

      @snapshot_filename = "production_unglobalcompact_#{@date}.sql"
      @extras_filename = "sessions_and_searchables_tables.sql"

      @snapshot_path = "#{@local_dir}/#{@snapshot_filename}"
      @extras_path = "#{@local_dir}/#{@extras_filename}"
    end

    def fetch_from_remote_host
      sync(@snapshot_filename)
      sync(@extras_filename)
      cleanup_old_snapshots
    end

    def restore_into_database
      recreate_database
      @strategy.restore(snapshot_path)
      @strategy.restore(extras_path)
      migrate
      create_dummy_accounts
      prepare_test_environment
      @strategy.post_restore_tasks
    end

    private

    def sync(filename)
      local_path = local_path(filename)
      remote_path = "#{@remote_dir}/#{filename}.gz"
      file = RemoteFile.new(@downloader, local_path, remote_path)
      file.download
    end

    def cleanup_old_snapshots
      Dir.glob("#{@local_dir}/*.*") do |path|
        unless [snapshot_path, extras_path].include?(path)
          FileUtils.rm(path, force: true)
        end
      end
    end

    def create_dummy_accounts
      puts "Creating dummy accounts"
      DummyAccounts.create
    end

    def choose_strategy(database_config)
      config = database_config.with_indifferent_access

      adapter = config.fetch(:adapter)
      database = config.fetch(:database)
      host = config[:host]
      username = config[:username]
      password = config[:password]

      case adapter
      when "mysql2" then Strategy::Mysql.new(database, host, username, password)
      when "postgresql" then Strategy::Postgres.new(database, host, username)
      else
        raise "No Snapshot adapter matching: #{adapter}"
      end
    end

    def local_path(filename)
      "#{@local_dir}/#{filename}"
    end

    def recreate_database
      puts "\nRecreating the database"
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
    end

    def migrate
      puts "Migrating development environment"
      Rake::Task["db:migrate"].invoke
    end

    def prepare_test_environment
      puts "Prepare test environment"
      Rake::Task["db:test:prepare"].invoke
    end

  end
end
