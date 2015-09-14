class BackgroundJobLogger < SimpleDelegator

  def initialize(log_filename = 'cop_reminder.log')
    file_logger = FileSystemLogger.new(log_filename)
    honeybadger = NotificationServiceLogger.new
    logger = CombinedLogger.new(file_logger, honeybadger)
    super(logger)
  end

end
