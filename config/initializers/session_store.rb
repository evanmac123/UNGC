# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_session_store, {
  key: 'ungc_session',
  redis: {
    db: 0,
    expire_after: 2.days,
    key_prefix: "ungc:#{Rails.env}:session:"
  }
}
