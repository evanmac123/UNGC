require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  def setup
    @organization = create_organization
    @organization.contacts.create(:email         => 'dude@example.com',
                                  :first_name    => 'a',
                                  :last_name     => 'b',
                                  :contact_point => true)
  end
  
  test "submission mailer is sent" do
    response = OrganizationMailer.deliver_submission_received(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "dude@example.com", response.to.first
  end
end
