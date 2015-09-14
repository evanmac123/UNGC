class CombinedLogger

  def initialize(*loggers)
    @loggers = *loggers
  end

  def info(message)
    @loggers.each do |logger|
      logger.info(message)
    end
  end

  def error(message, error = nil, params = {})
    @loggers.each do |logger|
      logger.info(message, error, params)
    end
  end

end
