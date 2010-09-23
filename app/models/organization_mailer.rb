class OrganizationMailer < ActionMailer::Base
  def submission_received(organization)
    subject "Your Letter of Commitment to the Global Compact"
    bcc ['globalcompact@un.org','vkeesari@yahoo.com']
    from EMAIL_SENDER
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
  def in_review(organization)
    from EMAIL_SENDER
    bcc 'globalcompact@un.org'
    subject "Your application to the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def in_review_local_network(organization)
    from EMAIL_SENDER
    cc 'filipic@un.org'
    bcc 'globalcompact@un.org'
    subject "#{organization.name}'s application to the Global Compact is under review"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first, :ceo => organization.contacts.ceos.first
  end
  
  def network_review(organization)
    from EMAIL_SENDER
    cc 'filipic@un.org'
    bcc 'globalcompact@un.org'
    subject "#{organization.name} has submitted an application to the Global Compact"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first, :ceo => organization.contacts.ceos.first
  end
  
  def approved_business(organization)
    from EMAIL_SENDER
    bcc 'globalcompact@un.org'
    subject "Welcome to the United Nations Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def approved_nonbusiness(organization)
    from EMAIL_SENDER
    bcc 'globalcompact@un.org'
    subject "Welcome to the United Nations Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def approved_local_network(organization)
    from EMAIL_SENDER
    bcc 'globalcompact@un.org'
    subject "#{organization.name} has been accepted into the Global Compact"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first, :ceo => organization.contacts.ceos.first
  end

  def reject_microenterprise(organization)
    from EMAIL_SENDER
    bcc 'globalcompact@un.org'
    subject "Your Letter of Commitment to the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
  def reject_microenterprise_network(organization)
    from EMAIL_SENDER
    bcc 'globalcompact@un.org'
    subject "#{organization.name}'s application to the Global Compact has been declined"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first, :ceo => organization.contacts.ceos.first
  end
  
  def foundation_invoice(organization)
    from 'foundation@unglobalcompact.org'
    cc 'contributions@globalcompactfoundation.org'
    bcc 'vkeesari@yahoo.com'
    subject "Your pledge to The Foundation for the Global Compact"
    content_type "text/html"
    recipients organization.financial_contact_or_contact_point.email_recipient
    body :organization => organization, :contact => organization.financial_contact_or_contact_point
  end

  def foundation_reminder(organization)
    from 'foundation@unglobalcompact.org'
    subject "A message from The Foundation for the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
end
