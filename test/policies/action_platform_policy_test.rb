require 'test_helper'

class ActionPlatformPolicyTest < ActiveSupport::TestCase

  context 'can create?' do
    context 'UNGC user' do
      should 'be allowed to view' do
        contact = build_stubbed(:staff_contact)
        policy = ActionPlatformPolicy.new(contact)
        assert policy.can_view?, 'UNGC contact should be able to view'
        assert_not policy.can_create?, 'UNGC contact should not be able to create'
        assert_not policy.can_edit?, 'UNGC contact should not be able to create'
        assert_not policy.can_destroy?, 'UNGC contact should not be able to create'
      end
    end


    context 'non UNGC user' do
      should 'not be allowed' do
        contact = build_stubbed(:contact)
        policy = ActionPlatformPolicy.new(contact)
        assert_not policy.can_create?, 'Non UNGC contact cannot create'
        assert_not policy.can_view?, 'Non UNGC contact cannot view'
        assert_not policy.can_edit?, 'UNGC contact cannot edit'
        assert_not policy.can_destroy?, 'UNGC contact cannot destroy'
      end
    end

    context 'action_platform_manager' do
      should 'be allowed' do
        contact = create(:staff_contact, :action_platform_manager)
        policy = ActionPlatformPolicy.new(contact)
        assert policy.can_create?, 'Action Platform Manager contact can create'
        assert policy.can_view?, 'Action Platform Manager contact can view'
        assert policy.can_edit?, 'Action Platform Manager contact can edit'
        assert policy.can_destroy?, 'Action Platform Manager contact can destroy'
      end
    end
  end
end
