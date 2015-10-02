class FileSystemLogger

  def initialize(filename)
    @logger = Logger.new(File.join(Rails.root, 'log', filename))
  end

  def info(message)
    @logger.info(timestamp(message))
  end

  def error(message, error = nil, params = {})
    @logger.error(timestamp(message, error))
  end

  private

  def timestamp(message, error)
    stamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    "#{stamp} : #{message} - #{error}"
  end

end
