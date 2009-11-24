class OrganizationMailer < ActionMailer::Base
  def submission_received(organization)
    subject "Your Letter of Commitment to the Global Compact"
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

  def reject_microenterprise(organization)
    from EMAIL_SENDER
    subject "Your Letter of Commitment to the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
  def foundation_invoice(organization)
    from 'Foundation for the Global Compact <foundation@unglobalcompact.org>'
    subject "Your pledge to The Foundation for the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end

  def foundation_reminder(organization)
    from 'Foundation for the Global Compact <foundation@unglobalcompact.org>'
    subject "A message from The Foundation for the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization, :contact => organization.contacts.contact_points.first
  end
  
end
