require "test_helper"

module Crm
  class ActionPlatformSyncJobTest < ActiveSupport::TestCase

    test "create an action platform" do
      platform = create(:action_platform_platform)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '6050D0000000001MVK'

      crm.expects(:create).with("Action_Platform__c", anything).returns(record_id)

      platform = platform.reload
      assert_nil platform.record_id

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:create, platform, {}, crm)

      refute_nil platform.record_id
      assert_equal record_id, platform.record_id
    end

    test "update an action platform" do
      platform = create(:action_platform_platform, :with_record_id)

      crm = mock("crm")
      crm.expects(:log)

      record_id = platform.record_id

      crm.expects(:update).with("Action_Platform__c", record_id, anything)

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:update, platform, {}, crm)

      refute_nil platform.record_id
      assert_equal record_id, platform.record_id
    end

    test "update an unsynced action platform, creates the action platform" do
      platform = create(:action_platform_platform)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '6050D0000000001MVK'

      crm.expects(:find).with('Action_Platform__c', platform.id.to_s, 'UNGC_Action_Platform_ID__c').returns(nil)
      crm.expects(:create).with("Action_Platform__c", anything).returns(record_id)

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:update, platform, {}, crm)

      refute_nil platform.record_id
      assert_equal record_id, platform.record_id
    end

    test "destroy an action platform" do
      platform = create(:action_platform_platform, :with_record_id)
      crm = mock("crm")
      crm.expects(:log)

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::ActionPlatform::PlatformSyncJob.perform_now(:destroy, nil, { record_id: platform.record_id }, crm)
    end
  end
end
