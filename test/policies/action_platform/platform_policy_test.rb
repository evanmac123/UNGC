require 'test_helper'

class ActionPlatformPolicyTest < ActiveSupport::TestCase

  context 'UNGC user' do
    should 'be allowed to view' do
      contact = build_stubbed(:staff_contact)
      policy = ActionPlatform::PlatformPolicy.new(contact)
      assert policy.can_view?, 'UNGC contact should be able to view'
      assert_not policy.can_create?, 'UNGC contact should not be able to create'
      assert_not policy.can_edit?, 'UNGC contact should not be able to edit'

      platform = build_stubbed(:action_platform_platform)
      assert_not policy.can_destroy?(platform), 'UNGC contact should not be able to destroy'
    end
  end

  context 'non UNGC user' do
    should 'not be allowed' do
      contact = build_stubbed(:contact)
      policy = ActionPlatform::PlatformPolicy.new(contact)
      assert_not policy.can_create?, 'Non UNGC contact cannot create'
      assert_not policy.can_view?, 'Non UNGC contact cannot view'
      assert_not policy.can_edit?, 'UNGC contact cannot edit'

      platform = build_stubbed(:action_platform_platform)
      assert_not policy.can_destroy?(platform), 'UNGC contact cannot destroy'
    end
  end

  context 'action_platform_manager' do
    should 'be allowed' do
      contact = create(:staff_contact, :action_platform_manager)
      policy = ActionPlatform::PlatformPolicy.new(contact)
      assert policy.can_create?, 'Action Platform Manager contact can create'
      assert policy.can_view?, 'Action Platform Manager contact can view'
      assert policy.can_edit?, 'Action Platform Manager contact can edit'

      platform = build_stubbed(:action_platform_platform)
      assert policy.can_destroy?(platform), 'Action Platform Manager contact can destroy'

      platform = create(:action_platform_platform, :with_subscriptions)
      assert_not policy.can_destroy?(platform), 'Action Platform Manager contact cannot destroy'
    end
  end

  context 'action_platform_manager' do
    should 'be allowed' do
      contact = create(:staff_contact, :website_editor)
      policy = ActionPlatform::PlatformPolicy.new(contact)
      assert policy.can_create?, 'website_editor contact can create'
      assert policy.can_view?, 'website_editor contact can view'
      assert policy.can_edit?, 'website_editor contact can edit'

      platform = build_stubbed(:action_platform_platform)
      assert policy.can_destroy?(platform), 'website_editor contact can destroy'

      platform = create(:action_platform_platform, :with_subscriptions)
      assert_not policy.can_destroy?(platform), 'website_editor contact cannot destroy'
    end
  end
end
