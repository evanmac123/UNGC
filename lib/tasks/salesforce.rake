require "faye"

namespace :salesforce do

  desc "listen for changes to a pushtopic"
  task listen: :environment do
    config = DEFAULTS[:salesforce]

    Restforce.log = true

    client = Restforce.new(
      api_version: "39.0",
      host: config.fetch(:host),
      username: config.fetch(:username),
      security_token: config.fetch(:token),
      password: config.fetch(:password),
      client_id: config.fetch(:client_id),
      client_secret: config.fetch(:client_secret)
    )

    client.authenticate!

    EM.run do
      client.subscribe 'ContactUpdates' do |message|
        ap message
      end
    end
  end

end
