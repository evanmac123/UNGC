if Rails.env.test?
  Sidekiq.logger.level = Logger::WARN
end
$redis = Sidekiq.redis { |conn| conn }
