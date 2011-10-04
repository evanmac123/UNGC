require 'test_helper'

class CopMailerTest < ActionMailer::TestCase
  
  context "given a submitted COP" do
    setup do
      create_organization_and_user
      @cop = create_cop(@organization.id)
    end

    should "send confirmation Learner email" do
      response = CopMailer.deliver_confirmation_learner(@organization, @cop, @organization_user)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Status - 12 Month Learner Grace Period", response.subject
      assert_equal @organization_user.email, response.to.first
    end 

    should "send confirmation Active email" do
      response = CopMailer.deliver_confirmation_active(@organization, @cop, @organization_user)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Status - GC Active", response.subject
      assert_equal @organization_user.email, response.to.first
    end 

    should "send confirmation Advanced email" do
      response = CopMailer.deliver_confirmation_advanced(@organization, @cop, @organization_user)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Status - GC Advanced", response.subject
      assert_equal @organization_user.email, response.to.first
    end 
    
  end
  
  context "given an organization with a Local Network" do
    setup do
      create_organization_and_user
      create_ungc_organization_and_user
      create_local_network_with_report_recipient
      @organization.update_attribute :country_id, @country.id
    end

    should "be able to send 90 days reminder" do
      response = CopMailer.deliver_cop_due_in_90_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact COP Deadline - 90 Days", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal @network_contact.email, response.cc.first
    end  

    should "be able to send 30 days reminder" do
      response = CopMailer.deliver_cop_due_in_30_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact COP Deadline - 30 Days", response.subject
      assert_equal @organization_user.email, response.to.first
      # do not send to Local Network
      assert_equal nil, response.cc
    end  
  
    should "be able to send today's reminder" do
      response = CopMailer.deliver_cop_due_today(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact COP Deadline - Today", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal @network_contact.email, response.cc.first
    end  
  end
  
  context "given a non-communicating organization with no Local Network" do
    setup do
      create_organization_and_user
      @organization.communication_late
      create_ungc_organization_and_user
    end

    should "be able to send notice of delisting in 3 months" do
      response = CopMailer.deliver_delisting_in_90_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Expulsion in 3 months", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal nil, response.cc
    end  

    should "be able to send 30 days until delisting" do
      response = CopMailer.deliver_delisting_in_30_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Urgent - UN Global Compact Expulsion in 30 days", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal nil, response.cc
    end  

    should "be able to send notice of delisting today" do
      response = CopMailer.deliver_delisting_today(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Status - Expelled", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal nil, response.cc
    end
  end  

  context "given a non-communicating organization with a Local Network" do
    setup do
      create_organization_and_user
      create_ungc_organization_and_user
      create_local_network_with_report_recipient
      @organization.update_attribute :country_id, @country.id
      @organization.communication_late
    end
    
    should "be able to send notice of delisting in 3 months" do
      response = CopMailer.deliver_delisting_in_90_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Expulsion in 3 months", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal nil, response.cc
    end

    should "copy Local Network on 30 days until delisting" do
      response = CopMailer.deliver_delisting_in_30_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Urgent - UN Global Compact Expulsion in 30 days", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal @network_contact.email, response.cc.first
    end  
    
    should "be able to send notice of delisting today" do
      response = CopMailer.deliver_delisting_today(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "UN Global Compact Status - Expelled", response.subject
      assert_equal @organization_user.email, response.to.first
      assert_equal @network_contact.email, response.cc.first
    end    
  end
  
end
