require 'minitest/autorun'

module Crm
  class LocalNetworkSyncJobTest < ActiveJob::TestCase

    context 'jobs' do
      setup do
        Rails.configuration.x_enable_crm_synchronization = true
        TestAfterCommit.enabled = true
      end

      teardown do
        Rails.configuration.x_enable_crm_synchronization = false
        TestAfterCommit.enabled = false
      end

      should 'should enqueue a job on create' do
        assert_enqueued_with(job: Crm::LocalNetworkSyncJob) do
          create(:local_network, name: "France")
        end
      end

      should 'conditionally enqueue a job on update' do
        network = create(:local_network, name: "France")

        assert_enqueued_with(job: Crm::LocalNetworkSyncJob) do
          network.update!(name: "Belgium")
        end

        assert_no_enqueued_jobs do
          network.update!(name: "Belgium")
          network.touch
        end
      end

      should 'conditionally enqueue a job on destroy' do
        local_network = create(:local_network)

        assert_enqueued_with(job: Crm::LocalNetworkSyncJob) do
          local_network.destroy!
        end
      end

    end

    test "create a local network" do
      network = create(:local_network)

      crm = mock("crm")
      crm.expects(:log)


      record_id = '01I0D0000000001MVK'

      crm.expects(:create).with("Account", anything).returns(record_id)

      network = network.reload
      assert_nil network.record_id

      Crm::LocalNetworkSyncJob.perform_now(:create, network, nil, crm)

      refute_nil network.record_id
      assert_equal record_id, network.record_id
    end

    test "update a local network" do
      network = build(:local_network, :with_record_id)

      crm = mock("crm")
      crm.expects(:log)

      record_id = network.record_id

      salesforce_object = Restforce::SObject.new(Id: record_id)
      crm.expects(:update).with("Account", record_id, anything).returns(salesforce_object)

      refute_nil network.record_id

      Crm::LocalNetworkSyncJob.perform_now(:update, network, network.changes, crm)

      refute_nil network.record_id
      assert_equal record_id, network.record_id
    end

    test "update an unsynced local network, creates the local network" do
      network = build(:local_network, record_id:  nil)
      changes = network.changes
      network.save!

      sf_ln_id = "LN-#{network.id}"

      crm = mock("crm")
      crm.expects(:log)

      record_id = '01I0D0000000001MVK'

      crm.expects(:find).with('Account', Crm::Adapters::LocalNetwork.convert_id(network.id), 'External_ID__c').returns(nil)
      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' &&
            params["External_ID__c"] == sf_ln_id &&
            params["Type"] == 'UNGC Local Network'
      end.returns(record_id)

      assert_nil network.record_id

      Crm::LocalNetworkSyncJob.perform_now(:update, network, changes, crm)

      refute_nil network.reload.record_id
      assert_equal record_id, network.record_id
    end

    test "update is skipped if nothing was updated by ActiveRecord" do
      network = build(:local_network, :with_record_id)

      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:update).never

      Crm::LocalNetworkSyncJob.perform_now(:update, network, nil, crm)
    end

    test "destroy a local network" do
      network = create(:local_network, :with_record_id)
      crm = mock("crm")
      crm.expects(:log)

      record_id = network.record_id

      crm.expects(:soft_delete).with("Account", record_id)

      assert_nil Crm::LocalNetworkSyncJob.perform_now(:destroy, nil, { record_id: [network.record_id, nil] }, crm)
    end
  end
end
