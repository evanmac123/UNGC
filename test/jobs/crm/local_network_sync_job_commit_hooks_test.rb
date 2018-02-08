require "test_helper"

module Crm
  class LocalNetworkSyncJobCommitHooksTest < ActiveSupport::TestCase

    setup do
      Rails.configuration.x_enable_crm_synchronization = true
      TestAfterCommit.enabled = true
    end

    teardown do
      Rails.configuration.x_enable_crm_synchronization = false
      TestAfterCommit.enabled = false
    end

    test "creating an organization also creates it in the CRM" do
      crm = mock_crm()

      network = create(:local_network, name: "France")

      crm_network = crm.find_local_network(network.id)
      assert_not_nil crm_network
      assert_equal "France", crm_network.Name
    end

    test "updating a local network also updates it in the CRM" do
      crm = mock_crm()

      network = create(:local_network, name: "France")
      network.update!(name: "Belgium")

      crm_network = crm.find_local_network(network.id)
      assert_not_nil crm_network
      assert_equal "Belgium", crm_network.Name
    end

    test "deleting a local network marks it as deleted in the CRM" do
      crm = mock_crm()

      network = create(:local_network)
      network.destroy!

      crm_network = crm.find_local_network(network.id)
      assert_equal true, crm_network.IsDeleted
    end

    private

    def mock_crm
      restforce = ::FakeRestforce.new
      ::Restforce.expects(:new).returns(restforce).at_least(0)
      Crm::Salesforce.new(restforce)
    end

  end

end
