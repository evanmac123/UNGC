require "test_helper"

class Admin::ActionPlatform::PlatformSubscriptionsControllerTest < ActionController::TestCase

  context "given a action platform manager user being signed in" do
    setup do
      @staff_user = create(:staff_contact, :action_platform_manager)
      sign_in @staff_user
    end

    context "given an existing platform and its subscription" do

      setup do
        create_list(:action_platform_subscription, 5)
        @platform = create(:action_platform_platform)
        @subscription = create(:action_platform_subscription, :platform   => @platform)
      end

      should "remove the subscription by posting to #destroy" do
        assert_difference 'ActionPlatform::Subscription.count', -1 do
          delete :destroy, id: @subscription
          assert_response :redirect
        end
      end

      should "approve the subscription by posting approve" do
        @subscription.update_attributes(state: :pending)
        patch :update, id: @subscription,
              commit: { approve: '' },
              subscription: { starts_on: @subscription.starts_on - 1.day}
        @subscription.reload
        assert @subscription.approved?
      end

      should "change the subscription contact" do
        @subscription.update_attributes(state: :pending)

        new_contact = create(:contact_point, organization: @subscription.organization)

        patch :update, id: @subscription,
              commit: { approve: '' },
              subscription: { contact_id: new_contact}

        @subscription.reload
        assert_equal @subscription.contact_id, new_contact.id, 'New contact ID was not saved'
      end

      should "send the subscription to CE Review" do
        @subscription.update_attributes(state: :pending)
        patch :update, id: @subscription,
              commit: { send_to_ce_review: '' },
              subscription: { starts_on: @subscription.starts_on - 1.day}
        @subscription.reload
        assert @subscription.ce_engagement_review?
      end

      should "revoke the subscription by posting a decline" do
        @subscription.update_attributes(state: :pending)
        patch :update, id: @subscription,
              commit: { decline: '' },
              subscription: { starts_on: @subscription.starts_on - 1.day}
        @subscription.reload
        assert @subscription.declined?
      end

      should "send the subscription to pending" do
        @subscription.update_attributes(state: :approved)
        patch :update, id: @subscription,
              commit: { back_to_pending: '' },
              subscription: { starts_on: @subscription.starts_on - 1.day}

        @subscription.reload
        assert @subscription.pending?
      end
    end
  end
end
