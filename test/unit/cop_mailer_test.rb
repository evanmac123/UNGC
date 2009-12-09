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
      assert_equal "email@example.com", response.to.first
    end  

    should "be able to send 30 days reminder" do
      response = CopMailer.deliver_cop_due_in_30_days(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your UN Global Compact participation - Communication on Progress required in 30 days", response.subject
      assert_equal "email@example.com", response.to.first
    end  
  
    should "be able to send today's reminder" do
      response = CopMailer.deliver_cop_due_today(@organization)
      assert_equal "text/html", response.content_type
      assert_equal "Your organization is Non-Communicating with the UN Global Compact", response.subject
      assert_equal "email@example.com", response.to.first
    end  
  end  
end
