class Downloader
  def initialize(host, user)
    @host = host
    @user = user
  end

  def download(from:, to:)
    Net::SCP.start(@host, @user) do |scp|
      scp.download!(from, to) do |ch, name, sent, total|
        progress = (sent.to_f/total.to_f * 100)
        $stdout.write sprintf("\rDownloading #{from}... %.1f%", progress)
        $stdout.flush
      end
    end
  end

end
