require 'test_helper'

class InvoiceReminderTest < ActiveSupport::TestCase
  context "given a new CopReminder object" do
    setup do
      @reminder = InvoiceReminder.new

      create_roles
      create_country

      @business_type = create_organization_type(
        name: 'Company',
        type_property: OrganizationType::BUSINESS
      )
      @non_business_type = create_organization_type(
        name: 'Academic',
        type_property: OrganizationType::NON_BUSINESS
      )

      # eligible for reminder email
      @org1 = create_organization(
        joined_on: 1.day.ago,
        pledge_amount: 0,
        participant: true,
        organization_type_id: @business_type.id
      )
      create_contact(
        :organization_id => Organization.first.id,
        :role_ids        => [Role.contact_point.id]
      )

      # eligible for invoice email
      @org2 = create_organization(
        joined_on: 1.day.ago,
        pledge_amount: 500,
        participant: true,
        organization_type_id: @business_type.id
      )
      create_contact(
        :organization_id => @org2.id,
        :role_ids        => [Role.contact_point.id]
      )

      # ineligible: created too recently
      @org3 = create_organization(
        joined_on: Time.now,
        pledge_amount: 500,
        participant: true,
        organization_type_id: @business_type.id
      )
      create_contact(
        :organization_id => @org3.id,
        :role_ids        => [Role.contact_point.id]
      )

      # ineligible: non business type
      @org4 = create_organization(
        joined_on: 1.day.ago,
        participant: true,
        organization_type_id: @non_business_type.id
      )
      create_contact(
        :organization_id => @org4.id,
        :role_ids        => [Role.contact_point.id]
      )
    end

    should "send appropriate mail to each organization" do
      OrganizationMailer.expects(:foundation_invoice).once
      OrganizationMailer.expects(:foundation_reminder).once

      @reminder.deliver_all
    end

    should "send email to all qualifying organizations" do
      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        @reminder.deliver_all
      end
    end
  end
end
