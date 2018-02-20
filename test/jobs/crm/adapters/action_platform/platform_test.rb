require "test_helper"

module Crm
  class ActionPlatformAdapterTest < ActiveSupport::TestCase

    test "it converts action platform UNGC ID to the format that the CRM expects" do
      platform = create(:crm_action_platform)

      assert_converts(platform,:create, 'UNGC_Action_Platform_ID__c', platform.id.to_s)
      assert_absent(platform,:update, 'UNGC_Action_Platform_ID__c')
    end

    test "it converts action platform description" do
      platform = create(:crm_action_platform, description: 'Hey!')
      platform.description = "There!"

      assert_converts(platform,:create, 'Description__c', platform.description)
      assert_converts(platform,:update, 'Description__c', platform.description)
    end


    test "it converts action platform name" do
      platform = create(:crm_action_platform, name: 'Hey!')

      assert_converts(platform,:create, 'Name', platform.name)
      platform.name = "There!"
      assert_converts(platform,:update, 'Name', platform.name)
    end

    test "it converts action platform discontinued status" do
      platform = create(:crm_action_platform)

      assert_is_nil(platform,:create, 'Status__c')

      platform = create(:crm_action_platform, discontinued: true)

      assert_converts(platform,:create, 'Status__c', 'discontinued')

      platform = create(:crm_action_platform, discontinued: false)
      platform.discontinued = false
      assert_is_nil(platform,:update, 'Status__c')
    end

    private

    def assert_converts(platform, action, key, expected_value)
      converted = Crm::Adapters::ActionPlatform::Platform.new(platform, action, platform.changes).crm_payload
      assert_equal expected_value, converted.fetch(key)
    end

    def assert_absent(platform, action, key)
      converted = Crm::Adapters::ActionPlatform::Platform.new(platform, action, platform.changes).crm_payload
      refute_includes converted.keys, key
    end

    def assert_is_nil(platform, action, key)
      converted = Crm::Adapters::ActionPlatform::Platform.new(platform, action, platform.changes).crm_payload
      assert_nil converted[key]
    end
  end
end
