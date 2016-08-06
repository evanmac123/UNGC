enabled = false

if enabled
  options = {
    host: 'staging.unglobalcompact.org',
    port: 443,
    session_key: 'ungc_session',
    redis: {
      host: 'localhost',
      port: 6379,
      db: 'rack-request-replication',
    }
  }

  Rails.application.config.middleware.use(
    Rack::RequestReplication::Forwarder,
    options
  )
end
