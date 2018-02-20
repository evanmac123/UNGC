require 'minitest/autorun'

module Crm
  class ActionPlatformSyncJobTest < ActiveJob::TestCase

    context 'jobs' do
      setup do
        Rails.configuration.x_enable_crm_synchronization = true
        TestAfterCommit.enabled = true
      end

      teardown do
        Rails.configuration.x_enable_crm_synchronization = false
        TestAfterCommit.enabled = false
      end

      should 'create an action platform enqueues job' do
        assert_enqueued_with(job: Crm::ActionPlatform::PlatformSyncJob) do
          create(:action_platform_platform)
        end
      end

      should 'update an action platform conditionally enqueues job' do
        platform = create(:action_platform_platform, name: "Sustainability")

        assert_enqueued_with(job: Crm::ActionPlatform::PlatformSyncJob) do
          platform.update!(name: "Destruction")
        end

        assert_no_enqueued_jobs do
          platform.update!(name: "Destruction")
          platform.touch
        end
      end

      should 'conditionally enqueue a job on destroy' do
        platform = create(:action_platform_platform)

        assert_enqueued_with(job: Crm::ActionPlatform::PlatformSyncJob) do
          platform.destroy!
        end
      end
    end

    test "create an action platform" do
      platform = create(:action_platform_platform)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '6050D0000000001MVK'

      crm.expects(:create).with("Action_Platform__c", anything).returns(record_id)

      platform = platform.reload
      assert_nil platform.record_id

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:create, platform, nil, crm)

      refute_nil platform.record_id
      assert_equal record_id, platform.record_id
    end

    test "update an action platform" do
      platform = build(:action_platform_platform, :with_record_id)

      crm = mock("crm")
      crm.expects(:log)

      record_id = platform.record_id

      crm.expects(:update).with("Action_Platform__c", record_id, anything)

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:update, platform, platform.changes, crm)

      refute_nil platform.record_id
      assert_equal record_id, platform.record_id
    end

    test "update an unsynced action platform, creates the action platform" do
      platform = build(:action_platform_platform)

      crm = mock("crm")
      crm.expects(:log)

      record_id = '6050D0000000001MVK'

      crm.expects(:find).with('Action_Platform__c', platform.id.to_s, 'UNGC_Action_Platform_ID__c').returns(nil)
      crm.expects(:create).with("Action_Platform__c", anything).returns(record_id)

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:update, platform, platform.changes, crm)

      refute_nil platform.record_id
      assert_equal record_id, platform.record_id
    end

    test "update is skipped if nothing was updated by ActiveRecord" do
      platform = build(:action_platform_platform, :with_record_id)

      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:update).with("Action_Platform__c", anything).never

      Crm::ActionPlatform::PlatformSyncJob.perform_now(:update, platform, nil, crm)
    end

    test "destroy an action platform" do
      platform = create(:action_platform_platform, :with_record_id)
      crm = mock("crm")
      crm.expects(:log)

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::ActionPlatform::PlatformSyncJob.perform_now(:destroy, nil, { record_id: [platform.record_id, nil] }, crm)
    end
  end
end
