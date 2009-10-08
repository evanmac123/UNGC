class OrganizationMailer < ActionMailer::Base
  def submission_received(organization)
    subject "We received your application"
    from EMAIL_SENDER
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email)
    body :organization => organization
  end
  
  def in_review(organization)
    from EMAIL_SENDER
    subject "Your Global Compact Participation Request has been updated"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email)
    body :organization => organization
  end
  
  def approved(organization)
    from EMAIL_SENDER
    subject "Your Global Compact Participation Request has been accepted"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email)
    body :organization => organization
  end

  def rejected(organization)
    from EMAIL_SENDER
    subject "Global Compact Participation Request Status"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email)
    body :organization => organization
  end
end
