require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  def setup
    @organization = create_organization
    @contact = create_contact(:organization_id => @organization.id,
                              :email           => 'dude@example.com')
  end
  
  test "submission mailer is sent" do
    response = OrganizationMailer.deliver_submission_received(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "dude@example.com", response.to.first
  end
end
