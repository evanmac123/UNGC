require "test_helper"
require "sidekiq/testing"

module Crm
  class LocalNetworkSyncTest < ActiveSupport::TestCase

    setup do
      Sidekiq::Testing.inline!
      Crm::CommitHooks.run_in_tests = true
      TestAfterCommit.enabled = true
    end

    teardown do
      Sidekiq::Testing.fake!
      Crm::CommitHooks.run_in_tests = false
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
