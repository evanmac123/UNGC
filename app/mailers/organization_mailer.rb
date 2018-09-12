# frozen_string_literal: true

class OrganizationMailer < ActionMailer::Base
  default :from => UNGC::Application::EMAIL_SENDER

  def submission_received(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "Your Letter of Commitment to the Global Compact"
  end

  def submission_jci_referral_received(organization)
    @organization = organization
    @ceo = organization.contacts.ceos.first
    mail \
      :to => ["externalrelations@jci.cc"],
      :subject => "New Global Compact referral"
  end

  def in_review(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "Your application to the Global Compact"
  end

  def in_review_local_network(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :cc => organization.participant_manager_email,
      :bcc => "archive@unglobalcompact.org",
      :subject => "#{organization.name}'s application to the Global Compact is under review"
  end

  def network_review(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :cc => organization.participant_manager_email,
      :bcc => "archive@unglobalcompact.org",
      :subject => "#{organization.name} has submitted an application to the Global Compact"
  end

  def approved_business(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "Welcome to the United Nations Global Compact"
  end

  def approved_nonbusiness(organization)
    @organization = organization
    @contact = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "Welcome to the United Nations Global Compact"
  end

  def approved_local_network(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "#{organization.name} has been accepted into the Global Compact"
  end

  def approved_city(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first

    mail \
      :to => ["elizabethryan@citiesprogramme.org"],
      :bcc => "archive@unglobalcompact.org",
      :subject => "#{organization.name} has been accepted into the Global Compact"
  end

  def reject_microenterprise(organization)
    @organization = organization
    @contact = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "Your Letter of Commitment to the Global Compact"
  end

  def reject_microenterprise_network(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :subject => "#{organization.name}'s application to the Global Compact has been declined"
  end

  def foundation_invoice(organization)
    @organization = organization
    @contact = organization.financial_contact_or_contact_point
    mail \
      :to => organization.financial_contact_and_contact_point.collect(&:email_recipient),
      :cc => ["contributions@globalcompactfoundation.org", organization.participant_manager_email],
      :bcc => ["archive@unglobalcompact.org"],
      :from => "foundation@unglobalcompact.org",
      :reply_to => organization.participant_manager_email,
      :subject => "[Invoice] The Foundation for the Global Compact"
  end

  def foundation_reminder(organization)
    @organization = organization
    @contact = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => "archive@unglobalcompact.org",
      :from => "foundation@unglobalcompact.org",
      :reply_to => organization.participant_manager_email,
      :subject => "A message from The Foundation for the Global Compact"
  end

  def level_of_participation_chosen(organization)
    @organization = organization
    @contact = organization.financial_contact_or_contact_point
    mail \
      to: organization.local_network.contacts.network_contacts.collect(&:email_recipient),
      bcc: ["archive@unglobalcompact.org"],
      from: "localnetworks@unglobalcompact.org",
      subject: "Engagement Tier '#{@organization&.level_of_participation&.humanize.titleize}' Selected By: #{organization.name}"
  end

  def join_organization(invite_id, params)
    @contact = Contact.new(params)
    @contact_params = params.except(:organization_id)
    @link = academy_viewer_accept_url(invite_id)

    mail \
      to: "info@unglobalcompact.org",
      bcc: ["academy@unglobalcompact.org", "ben@bitfield.co"],
      subject: "#{@contact.name} requesting to join #{@contact.organization.name}"
  end

  def claim_username(invite_id, params)
    contact = Contact.new(params)
    @contact_params = params.except(:organization_id)
    @link = academy_viewer_accept_url(invite_id)

    mail \
      to: "info@unglobalcompact.org",
      bcc: ["academy@unglobalcompact.org", "ben@bitfield.co", "alicino@unglobalcompact.org"],
      subject: "#{contact.name} from #{contact.organization.name} is requesting a username and password"
  end

end
