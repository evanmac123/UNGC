require 'test_helper'

class ActionPlatformSubscriptionPolicyTest < ActiveSupport::TestCase

  context 'can create?' do
    context 'UNGC user' do
      should 'be allowed to view' do
        contact = build_stubbed(:staff_contact)
        subscription = build_stubbed(:action_platform_subscription)
        policy = ActionPlatform::SubscriptionPolicy.new(subscription)
        assert policy.can_view?(contact), 'UNGC contact should be able to view'
        assert_not policy.can_create?(contact), 'UNGC contact should not be able to create'
        assert_not policy.can_edit?(contact), 'UNGC contact should not be able to create'
        assert_not policy.can_destroy?(contact), 'UNGC contact should not be able to create'
      end
    end

    context 'non UNGC user' do
      should 'not be allowed' do
        contact = build_stubbed(:contact)
        subscription = build_stubbed(:action_platform_subscription)
        policy = ActionPlatform::SubscriptionPolicy.new(subscription)
        assert_not policy.can_create?(contact), 'Non UNGC contact cannot create'
        assert_not policy.can_view?(contact), 'Non UNGC contact cannot view'
        assert_not policy.can_edit?(contact), 'UNGC contact cannot edit'
        assert_not policy.can_destroy?(contact), 'UNGC contact cannot destroy'
      end
    end

    context 'action_platform_manager' do
      should 'be allowed' do
        contact = create(:staff_contact, :action_platform_manager)
        subscription = build_stubbed(:action_platform_subscription, state: :pending)
        policy = ActionPlatform::SubscriptionPolicy.new(subscription)
        assert policy.can_create?(contact), 'Action Platform Manager contact can create'
        assert policy.can_view?(contact), 'Action Platform Manager contact can view'
        assert policy.can_edit?(contact), 'Action Platform Manager contact can edit'
        assert policy.can_destroy?(contact), 'Action Platform Manager contact can destroy'

        subscription.state = :approved
        assert_not policy.can_destroy?(contact), 'Action Platform Manager cannot destroy active Subscription'
      end
    end


    context 'website_editor' do
      should 'be allowed' do
        contact = create(:staff_contact, :website_editor)
        subscription = build_stubbed(:action_platform_subscription, state: :pending)
        policy = ActionPlatform::SubscriptionPolicy.new(subscription)
        assert policy.can_create?(contact), 'website_editor contact can create'
        assert policy.can_view?(contact), 'website_editor contact can view'
        assert policy.can_edit?(contact), 'website_editor contact can edit'
        assert policy.can_destroy?(contact), 'website_editor contact can destroy'

        subscription.state = :approved
        assert_not policy.can_destroy?(contact), 'website_editor cannot destroy active Subscription'
      end
    end

    context 'CE Manager' do
      should 'be allowed for organizations managed' do
        contact = create(:staff_contact)
        managed_organization = create(:organization, :active_participant, :with_contact, participant_manager: contact)
        subscription = build_stubbed(:action_platform_subscription,
                                     state: :pending,
                                     organization: managed_organization,
                                     contact: managed_organization.contacts.first)
        policy = ActionPlatform::SubscriptionPolicy.new(subscription)
        assert policy.can_create?(contact), 'Action Platform CE Manager contact can create'
        assert policy.can_view?(contact), 'Action Platform CE Manager contact can view'
        assert policy.can_edit?(contact), 'Action Platform CE Manager contact can edit'
        assert policy.can_destroy?(contact), 'Action Platform CE Manager contact can destroy'

        subscription.state = :approved
        assert_not policy.can_destroy?(contact), 'Action Platform CE Manager contact cannot destroy active Subscription'
      end

      should 'not be allowed for organizations not managed' do
        contact = create(:staff_contact)
        managed_organization = create(:organization, :active_participant, :with_contact, :has_participant_manager)
        subscription = build_stubbed(:action_platform_subscription,
                                     state: :pending,
                                     organization: managed_organization,
                                     contact: managed_organization.contacts.first)
        policy = ActionPlatform::SubscriptionPolicy.new(subscription)
        assert_not policy.can_create?(contact), 'Action Platform CE Manager contact cannot create'
        assert policy.can_view?(contact), 'Action Platform CE Manager contact cannot view'
        assert_not policy.can_edit?(contact), 'Action Platform CE Manager contact cannot edit'
        assert_not policy.can_destroy?(contact), 'Action Platform CE Manager contact cannot destroy'
      end
    end

  end
end
