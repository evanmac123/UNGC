require "test_helper"

module Crm
  class ActionPlatformSubscriptionAdapterTest < ActiveSupport::TestCase

    test "it converts action platform subscription UNGC ID to the format that the CRM expects" do
      model = create(:crm_action_platform_subscription)

      converted = convert_subscription(:create, model)

      assert_equal model.id, converted.fetch("UNGC_AP_Subscription_ID__c")

      model.expires_on = 3.years.from_now
      converted = convert_subscription(:update, model)

      refute converted.has_key?('UNGC_AP_Subscription_ID__c')
    end

    test "it converts action platform subscription created_at to the format that the CRM expects" do
      model = create(:crm_action_platform_subscription)

      converted = convert_subscription(:create, model)

      assert_equal model.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'), converted.fetch("Created_at__c")

      model.expires_on = 3.years.from_now
      converted = convert_subscription(:update, model)

      refute converted.has_key?('Created_at__c')
    end

    test "it creates an action platform subscription name < 80 chars" do
      model = create(:crm_action_platform_subscription)

      expected_name = "#{model.organization.name} - #{model.platform.name}"
      assert_converts(model,:create, 'Name', expected_name)

      model.expires_on = 3.years.from_now
      converted = convert_subscription(:update, model)
      refute converted.has_key?("Name")

      organization = create(:organization)
      model.organization = organization

      expected_name = "#{organization.name} - #{model.platform.name}"

      converted = convert_subscription(:update, model)
      assert_equal expected_name, converted.fetch("Name")
    end

    test "it creates a truncated at 80 action platform subscription name" do
      organization = create(:crm_organization, name: 'Organizing 123456789 123456789 123456789 123456789')
      platform = create(:crm_action_platform,  name: 'Platformer 123456789 123456789 123456789 123456789')

      model = create(:crm_action_platform_subscription, platform: platform, organization: organization)

      expected_name = 'Organizing 123456789 123456789 123456789 123456789 - Platformer 123456789 123...'
      assert_converts(model,:create, 'Name', expected_name)
    end

    test "it converts action platform subscription status" do
      model = create(:crm_action_platform_subscription, :approved)

      assert_converts(model,:create, 'Status__c', 'approved')

      model.expires_on = 3.years.from_now
      converted = convert_subscription(:update, model)
      refute converted.has_key?("Status__c")

      model.state = :ce_engagement_review
      converted = convert_subscription(:update, model)
      assert_equal 'ce_engagement_review', converted.fetch("Status__c")
    end

    test "it converts action platform starts on" do
      start = 1.month.from_now
      ends = 2.months.from_now
      model = create(:crm_action_platform_subscription, :approved, starts_on: start, expires_on: ends)

      assert_converts(model,:create, 'Starts_On__c', start.strftime('%F'))

      model.expires_on = 3.years.from_now
      converted = convert_subscription(:update, model)
      refute converted.has_key?("Status__c")

      start = 1.day.from_now
      model.starts_on = start
      converted = convert_subscription(:update, model)
      assert_equal start.strftime('%F'), converted.fetch("Starts_On__c")
    end

    test "it converts action platform expires on" do
      start = 1.month.from_now
      ends = 2.months.from_now
      model = create(:crm_action_platform_subscription, :approved, starts_on: start, expires_on: ends)

      assert_converts(model,:create, 'Expires_On__c', ends.strftime('%F'))

      start = 1.day.from_now
      model.starts_on = start
      converted = convert_subscription(:update, model)
      refute converted.has_key?("Expires_On__c")

      ends = 5.months.from_now
      model.expires_on = ends
      converted = convert_subscription(:update, model)
      assert_equal ends.strftime('%F'), converted.fetch("Expires_On__c")
    end

    private

    def assert_converts(subscription, action, key, expected_value)
      converted = convert_subscription(action, subscription)
      assert_equal expected_value, converted.fetch(key)
    end

    def convert_subscription(action, params = {})
      subscription = if params.respond_to?(:id)
        params # it is an contact
      else
        create(:crm_action_platform_subscription, params)
      end
      Crm::Adapters::ActionPlatform::Subscription.new(subscription, action, subscription.changes).crm_payload
    end
  end
end
