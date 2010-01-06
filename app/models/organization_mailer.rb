class OrganizationMailer < ActionMailer::Base
  def submission_received(organization)
    subject "Your Letter of Commitment to the Global Compact"
    bcc ['vnukova@un.org','vkeesari@yahoo.com']
    from EMAIL_SENDER
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
  def in_review(organization)
    from EMAIL_SENDER
    subject "Your application to the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
  def network_review(organization)
    from EMAIL_SENDER
    cc 'vnukova@un.org'
    bcc 'vkeesari@yahoo.com'
    subject "#{organization.name} has submitted a registration to the Global Compact"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first, :ceo => organization.contacts.ceos.first
  end
  
  def approved_business(organization)
    from EMAIL_SENDER
    subject "Welcome to the United Nations Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def approved_nonbusiness(organization)
    from EMAIL_SENDER
    subject "Welcome to the United Nations Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def approved_local_network(organization)
    from EMAIL_SENDER
    subject "#{organization.name} has been accepted into the Global Compact"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first, :ceo => organization.contacts.ceos.first
  end

  def reject_microenterprise(organization)
    from EMAIL_SENDER
    subject "Your Letter of Commitment to the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
  def foundation_invoice(organization)
    from 'foundation@unglobalcompact.org'
    bcc ['vkeesari@yahoo.com', 'gorre@globalcompactfoundation.org']
    subject "Your pledge to The Foundation for the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def foundation_reminder(organization)
    from 'foundation@unglobalcompact.org'
    subject "A message from The Foundation for the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
end
