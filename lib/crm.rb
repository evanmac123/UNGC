# frozen_string_literal: true

module Crm
  def self.create_client(config = DEFAULTS[:salesforce])
    Restforce.log = config.fetch(:debug, false)

    Restforce.new(
      api_version: config.fetch(:api_version, "41.0"),
      host: config.fetch(:host),
      username: config.fetch(:username),
      security_token: config.fetch(:token),
      password: config.fetch(:password),
      client_id: config.fetch(:client_id),
      client_secret: config.fetch(:client_secret)
    )
  end
end
