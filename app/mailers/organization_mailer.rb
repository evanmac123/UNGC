class OrganizationMailer < ActionMailer::Base
  default :from => EMAIL_SENDER

  def submission_received(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => ['globalcompact@un.org','vkeesari@yahoo.com'],
      :subject => "Your Letter of Commitment to the Global Compact"
  end

  def submission_jci_referral_received(organization)
    @organization = organization
    @ceo = organization.contacts.ceos.first
    mail \
      :to => ['externalrelations@jci.cc', 'vkeesari@yahoo.com'],
      :bcc => 'vkeesari@yahoo.com',
      :subject => "New Global Compact referral"
  end

  def in_review(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => 'globalcompact@un.org',
      :subject => "Your application to the Global Compact"
  end

  def in_review_local_network(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :cc => 'filipic@un.org',
      :bcc => 'globalcompact@un.org',
      :subject => "#{organization.name}'s application to the Global Compact is under review"
  end

  def network_review(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :cc => 'filipic@un.org',
      :bcc => 'globalcompact@un.org',
      :subject => "#{organization.name} has submitted an application to the Global Compact"
  end

  def approved_business(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => 'globalcompact@un.org',
      :subject => "Welcome to the United Nations Global Compact"
  end

  def approved_nonbusiness(organization)
    @organization = organization
    @contact = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => 'globalcompact@un.org',
      :subject => "Welcome to the United Nations Global Compact"
  end

  def approved_local_network(organization)
    @organization = organization
    @contact      = organization.contacts.contact_points.first
    @ceo          = organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => 'globalcompact@un.org',
      :subject => "#{organization.name} has been accepted into the Global Compact"
  end

  def reject_microenterprise(organization)
    @organization = organization
    @contact = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :bcc => 'globalcompact@un.org',
      :subject => "Your Letter of Commitment to the Global Compact"
  end

  def reject_microenterprise_network(organization)
    @organization => organization
    @contact => organization.contacts.contact_points.first
    @ceo => organization.contacts.ceos.first
    mail \
      :to => organization.network_report_recipients.collect(&:email_recipient),
      :bcc => 'globalcompact@un.org',
      :subject => "#{organization.name}'s application to the Global Compact has been declined"
  end

  def foundation_invoice(organization)
    @organization = organization
    @contact = organization.financial_contact_or_contact_point
    mail \
      :to => organization.financial_contact_or_contact_point.email_recipient,
      :cc => 'contributions@globalcompactfoundation.org',
      :bcc => 'vkeesari@yahoo.com',
      :from => 'foundation@unglobalcompact.org',
      :subject => "[Invoice] The Foundation for the Global Compact"
  end

  def foundation_reminder(organization)
    @organization = organization
    @contact = organization.contacts.contact_points.first
    mail \
      :to => organization.contacts.contact_points.collect(&:email_recipient),
      :from => 'foundation@unglobalcompact.org',
      :subject => "A message from The Foundation for the Global Compact"
  end

end
