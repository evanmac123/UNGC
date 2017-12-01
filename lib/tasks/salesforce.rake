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
      "africa@unglobalcompact.org"           => '005A0000003aYu4', # Ben
      "kimura@unglobalcompact.org"           => '005A0000003Ypfb', # Naoko
      "liu@unglobalcompact.org"              => '005A0000003Ypfb', # Naoko
      "chin@unglobalcompact.org"             => '005A0000003aYu4', # Ben
      "tarazi@unglobalcompact.org"           => '005A0000003YpfW', # Alex Tarazi
      "schriber@globalcompactfoundation.org" => '00512000005yehm', # Thorin
      "lima@unglobalcompact.org"             => '005A0000005ZOKV', # Carolina
      "skudem@unglobalcompact.org"           => '005120000063TB4', # Sigrun
    }.each do |email, salesforce_id|
      contact = Contact.find_by!(email: email)
      Crm::Owner.find_or_create_by(contact: contact) do |owner|
        owner.crm_id = salesforce_id
      end
    end
  end

end
