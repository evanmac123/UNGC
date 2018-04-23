module Snapshot
  module Strategy
    class Postgres
      attr_reader :remote_dir, :local_dir, :ssh_host

      def initialize(database, host, username, port = nil)
        @database = database
        @username = username
        @host = host
        @port = port || 5432
        @remote_dir = "/home/rails/ungc/pg_dumps"
        @local_dir = "./tmp/pg_snapshots"
        @ssh_host = "unglobalcompact.org"
      end

      def restore(snapshot_path)
        cmd = ['pg_restore', "-d #{@database}", "--no-owner", "--no-privileges"]
        cmd << "-U #{@username}" if @username.present?
        cmd << "-h #{@host}" if @host.present?
        cmd << "-p #{@port}"
        cmd << snapshot_path
        system(cmd.join(" "))
      end

      def post_restore_tasks
        puts "installing postgres extensions"
        Rake::Task["postgres:install_extentions"].invoke
      end

    end
  end
end
