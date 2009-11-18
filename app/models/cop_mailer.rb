class CopMailer < ActionMailer::Base
  def cop_due_in_90_days(organization)
    from EMAIL_SENDER
    subject "COP due in 90 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
  
  def cop_due_in_30_days(organization)
    from EMAIL_SENDER
    subject "COP due in 30 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def cop_due_today(organization)
    from EMAIL_SENDER
    subject "COP due today"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
end
