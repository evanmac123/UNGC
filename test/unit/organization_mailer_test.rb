require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  def setup
    create_organization_and_user
    create_ungc_organization_and_user
    create_organization_and_ceo
    create_financial_contact
    create_local_network_with_report_recipient
    @organization.country_id = @country.id
    @organization.comments.create(:contact_id => @staff_user.id,
                                  :body       => 'Lorem ipsum')
  end
  
  test "submission mailer is sent" do
    response = OrganizationMailer.deliver_submission_received(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Your Letter of Commitment to the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "submission mailer is sent to JCI" do
    response = OrganizationMailer.deliver_submission_jci_referral_received(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "New Global Compact referral", response.subject
    assert_equal "externalrelations@jci.cc", response.to.first
  end
  
  test "network review mailer sent" do
    response = OrganizationMailer.deliver_network_review(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "#{@organization.name} has submitted an application to the Global Compact", response.subject
    assert_equal @network_contact.email, response.to.first
  end
  
  test "non-business approved mailer is sent" do
    response = OrganizationMailer.deliver_approved_nonbusiness(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Welcome to the United Nations Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "business approved mailer is sent" do
    response = OrganizationMailer.deliver_approved_business(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Welcome to the United Nations Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "approved mailer to local network is sent" do
    response = OrganizationMailer.deliver_approved_local_network(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "#{@organization.name} has been accepted into the Global Compact", response.subject
    assert_equal @network_contact.email, response.to.first
  end

  test "in review mailer is sent" do
    response = OrganizationMailer.deliver_in_review(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Your application to the Global Compact", response.subject
    # FIXME: @organization_user is nil
    # assert_equal @organization_user.email, response.to.first
  end
  
  test "in review local network mailer is sent" do
    response = OrganizationMailer.deliver_in_review_local_network(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "#{@organization.name}'s application to the Global Compact is under review", response.subject
    assert_equal @network_contact.email, response.to.first
  end  
  
  test "rejected mailer is sent" do
    response = OrganizationMailer.deliver_reject_microenterprise(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "Your Letter of Commitment to the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end
  
  test "micro entrprise rejected mailer is sent to the local network" do
    response = OrganizationMailer.deliver_reject_microenterprise_network(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "#{@organization.name}'s application to the Global Compact has been declined", response.subject
    assert_equal @network_contact.email, response.to.first
  end
  
  test "foundation invoice is sent" do
    response = OrganizationMailer.deliver_foundation_invoice(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "[Invoice] The Foundation for the Global Compact", response.subject
    assert_equal @financial_contact.email, response.to.first
  end
  
  test "foundation reminder mailer is sent" do
    response = OrganizationMailer.deliver_foundation_reminder(@organization)
    assert_equal "text/html", response.content_type
    assert_equal "A message from The Foundation for the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end
end
