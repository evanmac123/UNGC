require "test_helper"

module Crm
  class ActionPlatformSubscriptionAdapterTest < ActiveSupport::TestCase

    test "it converts action platform subscription UNGC ID to the format that the CRM expects" do
      model = create(:crm_action_platform_subscription)

      assert_converts(model,:create, 'UNGC_AP_Subscription_ID__c', model.id)
      assert_absent(model,:update, 'UNGC_AP_Subscription_ID__c')
    end

    test "it converts action platform subscription created_at to the format that the CRM expects" do
      model = create(:crm_action_platform_subscription)

      assert_converts(model,:create, 'Created_at__c', model.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'))
      assert_absent(model,:update, 'Created_at__c')
    end

    test "it creates an action platform subscription name < 80 chars" do
      model = create(:crm_action_platform_subscription)

      expected_name = "#{model.organization.name} - #{model.platform.name}"
      assert_converts(model,:create, 'Name', expected_name)
      assert_converts(model,:update, 'Name', expected_name)
    end

    test "it creates a truncated at 80 action platform subscription name" do
      organization = create(:crm_organization, name: 'Organizing 123456789 123456789 123456789 123456789')
      platform = create(:crm_action_platform,  name: 'Platformer 123456789 123456789 123456789 123456789')

      model = create(:crm_action_platform_subscription, platform: platform, organization: organization)

      expected_name = 'Organizing 123456789 123456789 123456789 123456789 - Platformer 123456789 123...'
      assert_converts(model,:create, 'Name', expected_name)
      assert_converts(model,:update, 'Name', expected_name)
    end

    test "it converts action platform subscription status" do
      model = create(:crm_action_platform_subscription, :approved)

      assert_converts(model,:create, 'Status__c', 'approved')
      assert_converts(model,:update, 'Status__c', 'approved')
    end

    test "it converts action platform starts on" do
      start = 1.month.from_now
      ends = 2.months.from_now
      model = create(:crm_action_platform_subscription, :approved, starts_on: start, expires_on: ends)

      assert_converts(model,:create, 'Starts_On__c', start.strftime('%F'))
      assert_converts(model,:update, 'Starts_On__c', start.strftime('%F'))
    end

    test "it converts action platform expires on" do
      start = 1.month.from_now
      ends = 2.months.from_now
      model = create(:crm_action_platform_subscription, :approved, starts_on: start, expires_on: ends)

      assert_converts(model,:create, 'Expires_On__c', ends.strftime('%F'))
      assert_converts(model,:update, 'Expires_On__c', ends.strftime('%F'))
    end

    private

    def assert_converts(subscription, action, key, expected_value)
      converted = Crm::Adapters::ActionPlatform::Subscription.new(subscription).transformed_crm_params(action)
      assert_equal expected_value, converted.fetch(key)
    end

    def assert_absent(subscription, action, key)
      converted = Crm::Adapters::ActionPlatform::Subscription.new(subscription).transformed_crm_params(action)
      refute_includes converted.keys, key
    end

  end
end
