require 'test_helper'

class ContactMailerTest < ActionMailer::TestCase
  def setup
    create_organization_and_user
  end
  
  test "reset password mailer is sent" do
    response = ContactMailer.deliver_reset_password(@organization_user)
    assert_equal "text/html", response.content_type
    assert_equal "United Nations Global Compact - Reset Password", response.subject
    assert_equal @organization_user.email, response.to.first
  end
end
