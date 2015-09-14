class NotificationServiceLogger

  def initialize(notify_proc = nil)
    @notify = notify_proc || Honeybadger.method(:notify)
  end

  def info(message)
    # no-op for now
  end

  def error(message, error = nil, params = {})
    notify(
      error_class:    "CopStatusUpdater",
      error_message:  "#{message} #{error}",
      parameters:     params
    )
  end

  private

  def notify(params)
    @notify.call(params)
  end

end
