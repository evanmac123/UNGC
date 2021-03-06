require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase

  def setup
    create_ungc_organization_and_user
    create_organization_and_ceo
    create_financial_contact
    create_local_network_with_report_recipient
    @organization.country_id = @country.id
    @organization.participant_manager = create_participant_manager
    @organization.comments.create(contact_id: @staff_user.id, body: 'Lorem ipsum')
  end

  test "submission mailer is sent" do
    response = OrganizationMailer.submission_received(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Your Letter of Commitment to the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "submission mailer is sent to JCI" do
    response = OrganizationMailer.submission_jci_referral_received(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "New Global Compact referral", response.subject
    assert_equal "externalrelations@jci.cc", response.to.first
  end

  test "network review mailer sent" do
    response = OrganizationMailer.network_review(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "#{@organization.name} has submitted an application to the Global Compact", response.subject
    assert_equal @network_contact.email, response.to.first
    assert_contains response.cc, @organization.participant_manager_email
  end

  test "non-business approved mailer is sent" do
    response = OrganizationMailer.approved_nonbusiness(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Welcome to the United Nations Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "business approved mailer is sent" do
    response = OrganizationMailer.approved_business(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Welcome to the United Nations Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "approved mailer to local network is sent" do
    response = OrganizationMailer.approved_local_network(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "#{@organization.name} has been accepted into the Global Compact", response.subject
    assert_equal @network_contact.email, response.to.first
  end

  test "approved mailer to Cities Programme is sent" do
    response = OrganizationMailer.approved_city(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "#{@organization.name} has been accepted into the Global Compact", response.subject
    assert_equal 'elizabethryan@citiesprogramme.org', response.to.first
  end

  test "in review mailer is sent" do
    response = OrganizationMailer.in_review(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Your application to the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "in review local network mailer is sent" do
    response = OrganizationMailer.in_review_local_network(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "#{@organization.name}'s application to the Global Compact is under review", response.subject
    assert_equal @network_contact.email, response.to.first
    assert_contains response.cc, @organization.participant_manager_email
    assert_match(/Please feel free to contact #{@organization.participant_manager_name}/, response.encoded)
  end

  test "rejected mailer is sent" do
    response = OrganizationMailer.reject_microenterprise(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Your Letter of Commitment to the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "micro enterprise rejected mailer is sent to the local network" do
    response = OrganizationMailer.reject_microenterprise_network(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "#{@organization.name}'s application to the Global Compact has been declined", response.subject
    assert_equal @network_contact.email, response.to.first
  end

  test "foundation invoice is sent" do
    response = OrganizationMailer.foundation_invoice(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "[Invoice] The Foundation for the Global Compact", response.subject
    assert_contains response.to, @financial_contact.email
    assert_contains response.to, @organization_user.email
  end

  test "foundation reminder mailer is sent" do
    response = OrganizationMailer.foundation_reminder(@organization).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "A message from The Foundation for the Global Compact", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test 'Engagement Tier chosen notifies network' do
    country = create(:country, :with_local_network)
    organization = create(:organization, :participant_level, :has_participant_manager, country: country)

    mail = OrganizationMailer.level_of_participation_chosen(organization)

    assert_includes mail.subject, "Engagement Tier 'Participant Level' Selected By:"
    assert_includes mail.subject, organization.name
    assert_includes mail.to, organization.local_network.contacts.network_contacts.first.email,
      'Email not send to Network Focal Point contact'
    assert_nil mail.reply_to
    assert_equal ['localnetworks@unglobalcompact.org'], mail.from
  end

end
