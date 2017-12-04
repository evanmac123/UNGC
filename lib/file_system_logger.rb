class FileSystemLogger

  def initialize(filename)
    @logger = Logger.new(File.join(Rails.root, 'log', filename))
  end

  def info(message)
    @logger.info(timestamp(message))
  end

  def error(message, error = nil, params = {})
    msg = if error.present?
      "#{message} - #{error}"
    else
      message
    end
    @logger.error(timestamp(msg))
  end

  private

  def timestamp(message)
    stamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")
    "#{stamp} : #{message}"
  end

end
