module Snapshot
  class Downloader
    def initialize(host, user)
      @host = host
      @user = user
    end

    def download(remote_src, local_dest)
      Net::SCP.start(@host, @user) do |scp|
        scp.download!(remote_src, local_dest) do |ch, name, sent, total|
          progress = (sent.to_f/total.to_f * 100)
          $stdout.write sprintf("\rDownloading #{remote_src}... %.1f%", progress)
          $stdout.flush
        end
      end
    end

  end
end
