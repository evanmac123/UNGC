require "test_helper"

module Crm
  class LocalNetworkSyncJobTest < ActiveSupport::TestCase

    test "create a local network" do
      network = create(:local_network)

      crm = mock("crm")
      crm.expects(:log)


      record_id = '01I0D0000000001MVK'

      crm.expects(:create).with("Local_Network__c", anything).returns(record_id)

      network = network.reload
      assert_nil network.record_id

      Crm::LocalNetworkSyncJob.perform_now(:create, network, {}, crm)

      refute_nil network.record_id
      assert_equal record_id, network.record_id
    end

    test "update a local network" do
      network = create(:local_network, :with_record_id)

      crm = mock("crm")
      crm.expects(:log)

      record_id = network.record_id

      salesforce_object = Restforce::SObject.new(Id: record_id)
      crm.expects(:update).with("Local_Network__c", record_id, anything).returns(salesforce_object)

      refute_nil network.record_id

      Crm::LocalNetworkSyncJob.perform_now(:update, network, {}, crm)

      refute_nil network.record_id
      assert_equal record_id, network.record_id
    end

    test "update an unsynced local network, creates the local network" do
      network = create(:local_network, record_id:  nil)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '01I0D0000000001MVK'

      crm.expects(:find).with('Local_Network__c', Crm::Adapters::LocalNetwork.convert_id(network.id), 'External_ID__c').returns(nil)
      crm.expects(:create).with("Local_Network__c", anything).returns(record_id)

      assert_nil network.record_id

      Crm::LocalNetworkSyncJob.perform_now(:update, network, {}, crm)

      refute_nil network.reload.record_id
      assert_equal record_id, network.record_id
    end

    test "destroy a local network" do
      network = create(:local_network, :with_record_id)
      crm = mock("crm")
      crm.expects(:log)

      record_id = network.record_id

      crm.expects(:soft_delete).with("Local_Network__c", record_id)

      assert_nil Crm::LocalNetworkSyncJob.perform_now(:destroy, nil, { record_id: network.record_id }, crm)
    end
  end
end
