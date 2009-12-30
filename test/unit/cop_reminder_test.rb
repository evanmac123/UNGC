require 'test_helper'

class CopReminderTest < ActiveSupport::TestCase
  context "given a new CopReminder object" do
    setup do
      @reminder = CopReminder.new
      @business_organization_type = create_organization_type(:name          => 'Company',
                                                             :type_property => OrganizationType::BUSINESS)
      @non_business_organization_type = create_organization_type(:name => 'Academic',
                                                                 :type_property => OrganizationType::NON_BUSINESS)

      # adding organizations with COP due today, in 30 days and in 90 days
      create_organization(:cop_due_on           => Date.today,
                          :participant          => true,
                          :organization_type_id => @business_organization_type.id)

      create_organization(:cop_due_on           => 30.days.from_now.to_date,
                          :participant          => true,
                          :organization_type_id => @business_organization_type.id)

      create_organization(:cop_due_on           => 90.days.from_now.to_date,
                          :participant          => true,
                          :organization_type_id => @business_organization_type.id)

      # adding organizations that shouldn't be notified
      create_organization(:cop_due_on => 45.days.from_now.to_date)

      # not a participant
      create_organization(:cop_due_on           => Date.today,
                          :participant          => false,
                          :organization_type_id => @business_organization_type.id)
      # not a business
      create_organization(:cop_due_on           => Date.today,
                          :participant          => true,
                          :organization_type_id => @non_business_organization_type.id)
    end
    
    should "send email to the 1 organization with COP due for today" do
      assert_emails(1) do
        @reminder.notify_cop_due_today
      end
    end
    
    should "send email to the 1 organization with COP due in 30 days" do
      assert_emails(1) do
        @reminder.notify_cop_due_in_30_days
      end
    end
    
    should "send emails to the 1 organization with COP due in 90 days" do
      assert_emails(1) do
        @reminder.notify_cop_due_in_90_days
      end
    end

    should "send email to the 3 organizations when notifying all" do
      assert_emails(3) do
        @reminder.notify_all
      end
    end

    should "send emails to both an organization and its local network when COP is due in 90 days" do
      create_organization_and_user
      create_local_network_with_report_recipient    
      # organization with Local Network and Report Recipient, also due in 90 days
      @organization = create_organization(:cop_due_on           => 90.days.from_now.to_date,
                                          :participant          => true,
                                          :organization_type_id => @business_organization_type.id,
                                          :country_id           => @country.id)
      assert_equal 1, @organization.network_report_recipients.count                    
      assert_emails(2) do
        @reminder.notify_cop_due_in_90_days
      end
    end    
    
  end  
end
