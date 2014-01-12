require 'test_helper'

class CopReminderTest < ActiveSupport::TestCase
  context "given a new CopReminder object" do
    setup do
      @reminder = CopReminder.new
      @sme_organization_type          = create_organization_type(:name => 'SME',      :type_property => OrganizationType::BUSINESS)
      @business_organization_type     = create_organization_type(:name => 'Company',  :type_property => OrganizationType::BUSINESS)
      @non_business_organization_type = create_organization_type(:name => 'Academic', :type_property => OrganizationType::NON_BUSINESS)

      # adding organizations with COP due today, in 30 days and in 90 days, and one day ago
      create_organization(:cop_due_on           => Date.today,
                          :participant          => true,
                          :cop_state            => Organization::COP_STATE_ACTIVE,
                          :organization_type_id => @sme_organization_type.id)

      create_organization(:cop_due_on           => 30.days.from_now.to_date,
                          :participant          => true,
                          :cop_state            => Organization::COP_STATE_ACTIVE,
                          :organization_type_id => @business_organization_type.id)

      create_organization(:cop_due_on           => 90.days.from_now.to_date,
                          :participant          => true,
                          :cop_state            => Organization::COP_STATE_ACTIVE,                          
                          :organization_type_id => @business_organization_type.id)
                          
      create_organization(:cop_due_on           => Date.today.to_date - 1.day,
                          :participant          => true,
                          :cop_state            => Organization::COP_STATE_NONCOMMUNICATING,
                          :organization_type_id => @business_organization_type.id)
                          

      # adding organization about to be expelled in 90 days
      @non_communicating_org = create_organization(:cop_due_on           => 90.days.from_now.to_date - 1.year,
                                                   :participant          => true,
                                                   :organization_type_id => @business_organization_type.id)
      @non_communicating_org.communication_late
      
      # adding organization about to be expelled in 9 months
      create_organization(:cop_due_on           => 9.months.from_now.to_date - 1.year,
                          :participant          => true,
                          :cop_state            => Organization::COP_STATE_NONCOMMUNICATING,
                          :organization_type_id => @business_organization_type.id)

      # adding organization about to be expelled in 7 days
      create_organization(:cop_due_on           => 7.days.from_now.to_date - 1.year,
                          :participant          => true,
                          :cop_state            => Organization::COP_STATE_NONCOMMUNICATING,
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
      assert_difference 'ActionMailer::Base.deliveries.size' do
        @reminder.notify_cop_due_today
      end
    end

    should "send email to the 1 organization with COP due yesterday" do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        @reminder.notify_cop_due_yesterday
      end
    end

    should "send email to the 1 organization about to be expelled in 7 days" do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        @reminder.notify_cop_due_in_7_days
      end
    end

    should "send email to the 1 organization with COP due in 30 days" do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        @reminder.notify_cop_due_in_30_days
      end
    end    

    should "send email to 1 active organization with COP due in 90 days, and 1 non-communicating organization about to be expelled in 90 days" do
      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        @reminder.notify_cop_due_in_90_days
      end
    end
    
    should "send email to the 1 organization about to be expelled in 9 months" do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        @reminder.notify_cop_due_in_9_months
      end
    end

    should "send email to the 7 organizations when notifying all" do
      assert_difference 'ActionMailer::Base.deliveries.size', 7 do
        @reminder.notify_all
      end
    end

    should "send emails to 3 people with a COP due in 90 days" do
      create_organization_and_user
      create_local_network_with_report_recipient
      # organization with Local Network and Report Recipient, also due in 90 days
      @organization = create_organization(:cop_due_on           => 90.days.from_now.to_date,
                                          :participant          => true,
                                          :organization_type_id => @business_organization_type.id,
                                          :country_id           => @country.id)
      assert_equal 1, @organization.network_report_recipients.count
      assert_difference 'ActionMailer::Base.deliveries.size', 3 do
        @reminder.notify_cop_due_in_90_days
      end
    end

  end
end
