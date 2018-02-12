module Snapshot
  module Strategy
    class Postgres
      attr_reader :remote_dir, :local_dir, :ssh_host

      def initialize(database, host, username)
        @database = database
        @username = username
        @host = host
        @remote_dir = "/home/rails/ungc/pg_dumps"
        @local_dir = "./tmp/pg_snapshots"

        # TODO: stop pointing to staging after migrating to PG on production
        @ssh_host = "staging.unglobalcompact.org"
      end

      def restore(snapshot_path)
        cmd = ['pg_restore', "-d #{@database}", "--no-owner"]
        cmd << "-U #{@username}" if @username.present?
        cmd << "-h #{@host}" if @host.present?
        cmd << snapshot_path
        system cmd.join(" ").tap(&method(:ap))
      end

      def post_restore_tasks
        puts "installing postgres extensions"
        Rake::Task["postgres:install_extentions"].invoke
      end

    end
  end
end
