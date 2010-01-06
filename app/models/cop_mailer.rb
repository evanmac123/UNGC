class CopMailer < ActionMailer::Base
  def cop_due_in_90_days(organization)
    from EMAIL_SENDER
    subject "Your UN Global Compact participation - Communication on Progress required in 90 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def cop_due_in_90_days_notify_network(organization)
    from EMAIL_SENDER
    subject "#{organization.name} - Communication on Progress required in 90 days"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization
  end
  
  def cop_due_in_30_days(organization)
    from EMAIL_SENDER
    subject "Your UN Global Compact participation - Communication on Progress required in 30 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def cop_due_today(organization)
    from EMAIL_SENDER
    subject "Your organization is Non-Communicating with the UN Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
  
  def cop_due_today_notify_network(organization)
    from EMAIL_SENDER
    subject "#{organization.name} is Non-Communicating with the UN Global Compact"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization
  end
  
  def delisting_in_90_days(organization)
    from EMAIL_SENDER
    subject "Your organization is at risk of being delisted from the Global Compact in 90 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def delisting_in_30_days(organization)
    from EMAIL_SENDER
    subject "Your organization is at risk of being delisted from the Global Compact in 30 days"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end

  def delisting_in_30_days_notify_network(organization)
    from EMAIL_SENDER
    subject "#{organization.name} is at risk of being delisted from the Global Compact in 30 days"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization
  end

  def delisting_today(organization)
    from EMAIL_SENDER
    subject "Your organization has been delisted from the Global Compact"
    content_type "text/html"
    recipients organization.contacts.contact_points.collect(&:email_recipient)
    body :organization => organization
  end
  
  def delisting_today_notify_network(organization)
    from EMAIL_SENDER
    subject "#{organization.name} has been delisted from the Global Compact"
    content_type "text/html"
    recipients organization.network_report_recipients.collect(&:email_recipient)
    body :organization => organization
  end

end
