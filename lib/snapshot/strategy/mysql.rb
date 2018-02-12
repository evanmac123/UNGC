module Snapshot
  module Strategy
    class Mysql
      attr_reader :remote_dir, :local_dir, :ssh_host

      def initialize(database, host, username, password)
        @database = database
        @username = username
        @host = host
        @remote_dir = "/home/rails/ungc/mysql_dumps"
        @local_dir = "./tmp/snapshots"
        @ssh_host = "unglobalcompact.org"
      end

      def restore(snapshot_path)
        cmd = ['mysql', "-D", @database]
        cmd << "-u#{@username}" if @username.present?
        cmd << "-p#{@password}" if @password.present?
        cmd << "-h#{@host}" if @host.present?
        cmd << "< #{snapshot_path}"
        system cmd.join(" ").tap(&method(:ap))
      end

      def post_restore_tasks
        # no-op
      end

    end
  end
end
