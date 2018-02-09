require "test_helper"

module Crm
  class DonationSyncJobTest < ActiveSupport::TestCase

    test "create a donation" do
      donation = create(:donation)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '8050D0000000001MVK'

      crm.expects(:create).with('FGC_Paypal_Payments__c', anything).returns(record_id)

      assert_nil donation.record_id

      Crm::DonationSyncJob.perform_now(:create, donation, {}, crm)

      donation = donation.reload

      refute_nil donation.record_id
      assert_equal record_id, donation.record_id
    end

    test "update a donation does nothing" do
      donation = create(:donation, :with_record_id)

      crm = mock("crm")
      crm.expects(:log).never

      record_id = donation.record_id

      salesforce_object = Restforce::SObject.new(Id: record_id)
      crm.expects(:update).with('FGC_Paypal_Payments__c', record_id, anything).returns(salesforce_object).never

      refute_nil donation.record_id

      Crm::DonationSyncJob.perform_now(:update, donation, {}, crm)

      refute_nil donation.record_id
      assert_equal record_id, donation.record_id
    end

    test "destroy a donation" do
      donation = create(:donation, :with_record_id)
      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:destroy).never
      Crm::DonationSyncJob.perform_now(:destroy, nil, { record_id: donation.record_id }, crm)
    end
  end
end
