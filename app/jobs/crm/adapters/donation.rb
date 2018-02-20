# frozen_string_literal: true

module Crm
  module Adapters
    class Donation < Crm::Adapters::Base

      def build_crm_payload
        # NB we need to parse the raw stripe response
        # so that we can serialize it all back down as a single
        # JSON field.
        #
        column(Crm::DonationSyncJob::IdField, :id)
        column(Crm::DonationSyncJob::MetadataField, :metadata) do |donation|
          {
              ungc: donation.metadata,
              stripe_response: JSON.parse(donation.full_response),
          }.to_json
        end
      end
    end
  end
end
