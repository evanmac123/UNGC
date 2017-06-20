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

  desc "seed the salesforce contact => sf mapping"
  task seed_owners: :environment do
    {
      18334 => '005A00000039Eu7',  # Gordana
      32100 => '005A0000003aYu4',  # Ben
      38847 => '005A0000003YpfW',  # Alex Tarazi
      40613 => '005A0000003Ypfb',  # Naoko
      121481 => '00512000005yehm', # Thorin*/
      134581 => '005A0000005ZOKV', # Carolina
      137681 => '005120000063TB4', # Sigrun
    }.each do |contact_id, sf_id|
      Crm::Owner.create!(contact_id: contact_id, crm_id: sf_id)
    end
  end

end
