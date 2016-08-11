enabled = Rails.env.production?

if enabled
  options = {
    host: '107.170.30.145',
    port: 3000,
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
