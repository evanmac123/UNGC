require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  def setup
    create_organization_and_user
    create_ungc_organization_and_user
    @organization.comments.create(:contact_id => @staff_user.id,
                                  :body       => 'Lorem ipsum',
                                  )
  end
  
  test "submission mailer is sent" do
    response = OrganizationMailer.deliver_submission_received(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "We received your application", response.subject
    assert_equal "email@example.com", response.to.first
  end
  
  test "approved mailer is sent" do
    response = OrganizationMailer.deliver_approved(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Your Global Compact Participation Request has been accepted", response.subject
    assert_equal "email@example.com", response.to.first
  end

  test "in review mailer is sent" do
    response = OrganizationMailer.deliver_in_review(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Your Global Compact Participation Request has been updated", response.subject
    assert_equal "email@example.com", response.to.first
  end
  
  test "rejected mailer is sent" do
    response = OrganizationMailer.deliver_reject_microenterprise(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Global Compact Participation Request Status", response.subject
    assert_equal "email@example.com", response.to.first
  end
end
