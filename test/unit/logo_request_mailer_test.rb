require 'test_helper'

class LogoRequestMailerTest < ActionMailer::TestCase
  def setup
    create_approved_logo_request
  end
  
  test "in review mailer is sent" do
    response = LogoRequestMailer.deliver_in_review(@logo_request)
    assert_equal "text/html", response.content_type
    assert_equal "Your Global Compact Logo Request has been updated", response.subject
    assert_equal "email@example.com", response.to.first
  end
  
  test "approved mailer is sent" do
    response = LogoRequestMailer.deliver_approved(@logo_request)
    assert_equal "text/html", response.content_type
    assert_equal "Your Global Compact Logo Request has been accepted", response.subject
    assert_equal "email@example.com", response.to.first
  end
  
  test "rejected mailer is sent" do
    response = LogoRequestMailer.deliver_rejected(@logo_request)
    assert_equal "text/html", response.content_type
    assert_equal "Global Compact Logo Request Status", response.subject
    assert_equal "email@example.com", response.to.first
  end
end