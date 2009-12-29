require 'test_helper'

class CopReminderTest < ActiveSupport::TestCase
  context "given a new CopReminder object" do
    setup do
      @reminder = CopReminder.new
      @business_organization_type = create_organization_type(:name => 'Company')
      @non_business_organization_type = create_organization_type(:name => 'Academic')

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
    
    should "send email to the 1 organization with COP due in 90 days" do
      assert_emails(1) do
        @reminder.notify_cop_due_in_90_days
      end
    end

    should "send email to the 3 organizations when notifying all" do
      assert_emails(3) do
        @reminder.notify_all
      end
    end
  end  
end
