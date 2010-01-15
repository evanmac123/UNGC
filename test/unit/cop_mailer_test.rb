require 'test_helper'

class CopMailerTest < ActionMailer::TestCase
  context "given an organization" do
    setup do
      create_organization_and_user
      create_ungc_organization_and_user
    end

    should "be able to send 90 days reminder" do
      response = CopMailer.deliver_cop_due_in_90_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your UN Global Compact participation - Communication on Progress required in 90 days", response.subject
      assert_equal @organization_user.email, response.to.first
    end  

    should "be able to send 30 days reminder" do
      response = CopMailer.deliver_cop_due_in_30_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your UN Global Compact participation - Communication on Progress required in 30 days", response.subject
      assert_equal @organization_user.email, response.to.first
    end  
  
    should "be able to send today's reminder" do
      response = CopMailer.deliver_cop_due_today(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your organization is Non-Communicating with the UN Global Compact", response.subject
      assert_equal @organization_user.email, response.to.first
    end  
  end
  
  context "given a non-communicating organization" do
    setup do
      create_organization_and_user
      @organization.communication_late
      create_ungc_organization_and_user
    end

    should "be able to send 90 days until delisting" do
      response = CopMailer.deliver_delisting_in_90_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your organization is at risk of being delisted from the Global Compact in 90 days", response.subject
      assert_equal @organization_user.email, response.to.first
    end  

    should "be able to send 30 days until delisting" do
      response = CopMailer.deliver_delisting_in_30_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your organization is at risk of being delisted from the Global Compact in 30 days", response.subject
      assert_equal @organization_user.email, response.to.first
    end  

    should "be able to send notice of delisting today" do
      response = CopMailer.deliver_delisting_today(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your organization has been delisted from the Global Compact", response.subject
      assert_equal @organization_user.email, response.to.first
    end
  end  

  context "given a non-communicating organization with a local network" do
    setup do
      create_organization_and_user
      create_local_network_with_report_recipient
      @organization = create_organization(:name => 'non-communcation-company', :country_id => @country.id)
      @organization.communication_late
    end

    should "be able to send 90 days until delisting to network report recipient" do
      response = CopMailer.deliver_cop_due_in_90_days_notify_network(@organization)
      assert_equal 1, @organization.network_report_recipients.count
      assert_equal "text/html", response.content_type
      assert_equal "#{@organization.name} - Communication on Progress required in 90 days", response.subject
      assert_equal @network_contact.email, response.to.first
    end
    
    should "be able to send 30 days until delisting to local network" do
      response = CopMailer.deliver_delisting_in_30_days_notify_network(@organization)
      assert_equal 1, @organization.network_report_recipients.count
      assert_equal "text/html", response.content_type
      assert_equal "#{@organization.name} is at risk of being delisted from the Global Compact in 30 days", response.subject
      assert_equal @network_contact.email, response.to.first
    end
    
    should "be able to send notice of delisting today to network report recipient" do
      response = CopMailer.deliver_delisting_today_notify_network(@organization)
      assert_equal 1, @organization.network_report_recipients.count
      assert_equal "text/html", response.content_type
      assert_equal "#{@organization.name} has been delisted from the Global Compact", response.subject
      assert_equal @network_contact.email, response.to.first
    end
  end
  
end
