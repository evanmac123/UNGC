class CopMailer < ActionMailer::Base
  helper :datetime

  def cop_due_in_90_days(organization)
    from EMAIL_SENDER
    cc organization.network_report_recipients.collect(&:email_recipient)
    bcc 'vkeesari@yahoo.com'
    subject "UN Global Compact COP Deadline - 90 Days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
  
  def cop_due_in_30_days(organization)
    from EMAIL_SENDER
    bcc 'vkeesari@yahoo.com'
    subject "UN Global Compact COP Deadline - 30 Days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def cop_due_today(organization)
    from EMAIL_SENDER
    cc organization.network_report_recipients.collect(&:email_recipient)
    bcc 'vkeesari@yahoo.com'
    subject "UN Global Compact COP Deadline - Today"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
    
  def delisting_in_90_days(organization)
    from EMAIL_SENDER
    bcc 'vkeesari@yahoo.com'
    subject "UN Global Compact Expulsion in 3 months"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def delisting_in_30_days(organization)
    from EMAIL_SENDER
    cc organization.network_report_recipients.collect(&:email_recipient)
    bcc 'vkeesari@yahoo.com'
    subject "Urgent - UN Global Compact Expulsion in 30 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def delisting_today(organization)
    from EMAIL_SENDER
    cc organization.network_report_recipients.collect(&:email_recipient)
    bcc 'vkeesari@yahoo.com'
    subject "UN Global Compact Status - Expelled"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
  
end