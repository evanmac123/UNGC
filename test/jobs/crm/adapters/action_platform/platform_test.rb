require "test_helper"

module Crm
  class ActionPlatformAdapterTest < ActiveSupport::TestCase

    test "it converts action platform UNGC ID to the format that the CRM expects" do
      platform = create(:crm_action_platform)

      assert_converts(platform,:create, 'UNGC_Action_Platform_ID__c', platform.id.to_s)
      assert_absent(platform,:update, 'UNGC_Action_Platform_ID__c')
    end

    test "it converts action platform description" do
      platform = create(:crm_action_platform)

      assert_converts(platform,:create, 'Description__c', platform.description)
      assert_converts(platform,:update, 'Description__c', platform.description)
    end

    test "it converts action platform name" do
      platform = create(:crm_action_platform)

      assert_converts(platform,:create, 'Name', platform.name)
      assert_converts(platform,:update, 'Name', platform.name)
    end

    test "it converts action platform discontinued status" do
      platform = create(:crm_action_platform)

      assert_absent(platform,:create, 'Status__c')
      assert_absent(platform,:update, 'Status__c')

      platform = create(:crm_action_platform, discontinued: true)

      assert_converts(platform,:create, 'Status__c', 'discontinued')
      assert_converts(platform,:update, 'Status__c', 'discontinued')
    end

    private

    def assert_converts(platform, action, key, expected_value)
      converted = Crm::Adapters::ActionPlatform::Platform.new(platform).transformed_crm_params(action)
      assert_equal expected_value, converted.fetch(key)
    end

    def assert_absent(platform, action, key)
      converted = Crm::Adapters::ActionPlatform::Platform.new(platform).transformed_crm_params(action)
      refute_includes converted.keys, key
    end

  end
end
