require "test_helper"
require "sidekiq/testing"

module Crm
  class ActionSubscriptionSubscriptionTest < ActiveSupport::TestCase

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

    test "creating a Subscription also creates it in the CRM" do
      crm = mock_crm()

      organization = create(:organization, :with_sector)
      subscription = create(:action_platform_subscription,
        created_at: DateTime.new(2017, 3, 4, 17, 45, 0),
        expires_on: Date.new(2018, 3, 4),
        status: :approved,
        organization: organization)

      crm_subscription = crm.find_action_platform_subscription(subscription.id)
      assert_not_nil crm_subscription
      assert_not_nil crm_subscription.Id
      assert_equal "2017-03-04T17:45:00.000Z", crm_subscription.Created_at__c
      assert_equal "2018-03-04", crm_subscription.Expires_On__c
      assert_equal "approved", crm_subscription.Status__c
      assert_equal subscription.id, crm_subscription.UNGC_AP_Subscription_ID__c
      assert_not_nil crm_subscription.Action_Platform__c
      assert_not_nil crm_subscription.Contact_Point__c
      assert_not_nil crm_subscription.Organization__c
    end

    test "updating a Subscription also updates it in the CRM" do
      crm = mock_crm()

      subscription = create(:action_platform_subscription, :approved,
        expires_on: "2018-03-04")
      subscription.update!(expires_on: "2019-01-01")

      sub = crm.find_action_platform_subscription(subscription.id)
      assert_not_nil sub
      assert_equal "approved", sub.Status__c
    end

    test "deleting an Subscription marks it as deleted in the CRM" do
      crm = mock_crm()

      subscription = create(:action_platform_subscription, :approved)
      subscription.destroy!

      crm_subscription = crm.find_action_platform_subscription(subscription.id)
      assert_nil crm_subscription
    end

    test "only approved subscriptions are synced" do
      _crm = mock_crm()

      approved = create(:action_platform_subscription, status: :approved)
      pending = create(:action_platform_subscription, status: :pending)

      assert Crm::ActionPlatformSubscriptionSync.should_sync?(approved)
      refute Crm::ActionPlatformSubscriptionSync.should_sync?(pending)
    end

    private

    def mock_crm
      restforce = ::FakeRestforce.new
      ::Restforce.expects(:new).returns(restforce).at_least(0)
      Crm::Salesforce.new(restforce)
    end
  end
end
