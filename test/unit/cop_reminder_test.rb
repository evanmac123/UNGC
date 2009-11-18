require 'test_helper'

class CopReminderTest < ActiveSupport::TestCase
  context "given a new CopReminder object" do
    setup do
      @reminder = CopReminder.new
      # we organizations with COP due today, in 30 days and in 90 days
      create_organization_type
      create_organization(:cop_due_on => Date.today)
      create_organization(:cop_due_on => 30.days.from_now.to_date)
      create_organization(:cop_due_on => 90.days.from_now.to_date)
      # adding a organization that shouldn't be notified
      create_organization(:cop_due_on => 45.days.from_now.to_date)
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
