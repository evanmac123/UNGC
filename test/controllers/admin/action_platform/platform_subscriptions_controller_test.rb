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
          delete :destroy, :id => @subscription
          assert_response :redirect
        end
      end

      should "approve the subscription by posting to #approve" do
        @subscription.pending!
        post :approve, :id => @subscription
        @subscription.reload
        assert @subscription.approved?
      end

      should "revoke the subscription by posting to #revoke" do
        @subscription.approved!
        post :revoke, :id => @subscription
        @subscription.reload
        assert @subscription.pending?
      end

    end
  end
end
