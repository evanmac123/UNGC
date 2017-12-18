require "test_helper"
require "sidekiq/testing"

module Crm
  class ActionPlatformSyncTest < ActiveSupport::TestCase

    setup do
      Sidekiq::Testing.inline!
      Rails.configuration.x_enable_crm_synchronization = true
      TestAfterCommit.enabled = true
    end

    teardown do
      Sidekiq::Testing.fake!
      Rails.configuration.x_enable_crm_synchronization = false
      TestAfterCommit.enabled = false
    end

    test "creating an Action Platform also creates it in the CRM" do
      crm = mock_crm()

      platform = create(:action_platform,
        name: "One",
        description: "description",
        discontinued: true)

      crm_platform = crm.find_action_platform(platform.id)
      assert_not_nil crm_platform
      assert_equal "One", crm_platform.Name
      assert_equal "description", crm_platform.Description__c
      assert_equal "discontinued", crm_platform.Status__c
    end

    test "updating a Action Platform also updates it in the CRM" do
      crm = mock_crm()

      platform = create(:action_platform, name: "One")
      platform.update!(name: "Two")

      crm_platform = crm.find_action_platform(platform.id)
      assert_not_nil crm_platform
      assert_equal "Two", crm_platform.Name
    end

    test "deleting an Action Platform marks it as deleted in the CRM" do
      crm = mock_crm()

      platform = create(:action_platform)
      platform.destroy!

      crm_platform = crm.find_action_platform(platform.id)
      assert_nil crm_platform
    end

    private

    def mock_crm
      restforce = ::FakeRestforce.new
      ::Restforce.expects(:new).returns(restforce).at_least(0)
      Crm::Salesforce.new(restforce)
    end

  end

end
