require 'test_helper'

class InvoiceReminderTest < ActiveSupport::TestCase
  context "given a new InvoiceReminder object" do
    setup do
      @reminder = InvoiceReminder.new

      create(:country)

      @business_type = create(:organization_type,
        name: 'Company',
        type_property: OrganizationType::BUSINESS
      )
      @non_business_type = create(:organization_type,
        name: 'Academic',
        type_property: OrganizationType::NON_BUSINESS
      )

      # eligible for reminder email
      @org1 = create(:organization,
        joined_on: 2.day.ago,
        pledge_amount: 0,
        participant: true,
        organization_type_id: @business_type.id
      )
      create(:contact,
        :organization_id => Organization.first.id,
        :role_ids        => [Role.contact_point.id]
      )

      # eligible for invoice email
      @org2 = create(:organization,
        joined_on: 2.day.ago,
        pledge_amount: 500,
        participant: true,
        organization_type_id: @business_type.id
      )
      create(:contact,
        :organization_id => @org2.id,
        :role_ids        => [Role.contact_point.id]
      )

      # ineligible: created too recently
      @org3 = create(:organization,
        joined_on: Time.now,
        pledge_amount: 500,
        participant: true,
        organization_type_id: @business_type.id
      )
      create(:contact,
        :organization_id => @org3.id,
        :role_ids        => [Role.contact_point.id]
      )

      # ineligible: non business type
      @org4 = create(:organization,
        joined_on: 1.day.ago,
        participant: true,
        organization_type_id: @non_business_type.id
      )
      create(:contact,
        :organization_id => @org4.id,
        :role_ids        => [Role.contact_point.id]
      )
    end

    should "send appropriate mail to each organization" do
      assert_difference 'ActionMailer::Base.deliveries.size', +2 do
        @reminder.deliver_all
      end

      reminder_email, invoice_email = ActionMailer::Base.deliveries[-2, 2]
      assert_equal "[Invoice] The Foundation for the Global Compact", invoice_email.subject
      assert_equal "A message from The Foundation for the Global Compact", reminder_email.subject
    end

    should "send email to all qualifying organizations" do
      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        @reminder.deliver_all
      end
    end
  end
end
