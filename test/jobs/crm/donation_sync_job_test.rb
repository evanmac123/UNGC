require 'minitest/autorun'

module Crm
  class DonationSyncJobTest < ActiveJob::TestCase

    context 'jobs' do
      setup do
        Rails.configuration.x_enable_crm_synchronization = true
        TestAfterCommit.enabled = true
      end

      teardown do
        Rails.configuration.x_enable_crm_synchronization = false
        TestAfterCommit.enabled = false
      end

      should 'enqueue no job on create' do
        organization = create(:organization)
        contact = create(:contact, organization: organization)

        assert_no_enqueued_jobs do
          create(:donation, organization: organization, contact: contact)
        end
      end

      should 'enqueue no job on update' do
        model = create(:donation)

        assert_no_enqueued_jobs do
          model.update!(amount: 30)
        end
      end

      should 'conditionally eno job on destroy' do
        model = create(:donation)

        assert_no_enqueued_jobs do
          model.destroy!
        end
      end

    end

    test "create a donation" do
      donation = create(:donation)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '8050D0000000001MVK'

      crm.expects(:create).with('FGC_Paypal_Payments__c', anything).returns(record_id)

      assert_nil donation.record_id

      Crm::DonationSyncJob.perform_now(:create, donation, nil, crm)

      donation = donation.reload

      refute_nil donation.record_id
      assert_equal record_id, donation.record_id
    end

    test "update a donation does nothing" do
      donation = build(:donation, :with_record_id)

      crm = mock("crm")
      crm.expects(:log).never

      record_id = donation.record_id

      salesforce_object = Restforce::SObject.new(Id: record_id)
      crm.expects(:update).with('FGC_Paypal_Payments__c', record_id, anything).returns(salesforce_object).never

      refute_nil donation.record_id

      Crm::DonationSyncJob.perform_now(:update, donation, donation.changes, crm)

      refute_nil donation.record_id
      assert_equal record_id, donation.record_id
    end

    test "destroy a donation" do
      donation = create(:donation, :with_record_id)
      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:destroy).never
      Crm::DonationSyncJob.perform_now(:destroy, nil, { record_id: [donation.record_id, nil] }, crm)
    end
  end
end
