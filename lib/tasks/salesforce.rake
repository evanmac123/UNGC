# frozen_string_literal: true

require "faye"

namespace :salesforce do

  desc "starts the pushtopic listener daemon"
  task start_listener: :environment do
    listener = Crm::Listener.new(
      log_file: ENV["LOGFILE"],
      pid_file: ENV["PIDFILE"]
    )
    Rails.logger = listener.logger
    listener.listen
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
