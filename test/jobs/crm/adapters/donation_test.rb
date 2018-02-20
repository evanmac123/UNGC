require "test_helper"

module Crm
  class DonationAdapterTest < ActiveSupport::TestCase

    test "It converts IdField" do
      assert converted.has_key?('Paypal_Transaction_ID__c')
    end

    test "It converts MetadataField" do
      assert converted.has_key?('Metadata__c')
    end

    private

    def converted(model_params = {})
      donation = build_stubbed(:donation, model_params)

      Crm::Adapters::Donation.new(donation, :create).crm_payload
    end

  end
end
