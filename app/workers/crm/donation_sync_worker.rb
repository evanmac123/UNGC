module Crm
  class DonationSyncWorker
    include Sidekiq::Worker

    def self.sync(donation)
      self.perform_async(donation.id)
    end

    def perform(donation_id)
      donation = Donation.find(donation_id)
      Crm::DonationSync.new.upsert(donation)
    end

  end
end
