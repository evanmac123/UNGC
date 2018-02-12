require 'net/scp'

module Snapshot
  class RemoteFile
    def initialize(downloader, local_path, remote_path)
      @downloader = downloader
      @local_path = local_path
      @remote_path = remote_path
      @zip_path = "#{local_path}.gz"
    end

    def download
      return if exists_locally?

      ensure_local_dir_exists
      download_file unless zip_exists_locally?
      unzip_file

      @local_path
    end

    private

    def unzip_file
      system "gunzip #{@zip_path}"
    end

    def download_file(&block)
      @downloader.download(@remote_path, @zip_path)
    end

    def exists_locally?
      File.exist?(@local_path)
    end

    def zip_exists_locally?
      File.exist?(@zip_path)
    end

    def ensure_local_dir_exists
      FileUtils.mkdir_p(File.dirname(@local_path))
    end

  end
end
