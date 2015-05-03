if Rails.env.test?
  Sidekiq.logger.level = Logger::WARN
end
