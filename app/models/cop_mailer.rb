class CopMailer < ActionMailer::Base
  helper :datetime


  def confirmation_blueprint(organization, cop, user)
    from 'lead@unglobalcompact.org'
    cc 'lead@unglobalcompact.org'
    subject "Global Compact LEAD - COP Status"
    content_type "text/html"
    recipients user.email_recipient
    body :organization => organization, :cop => cop, :user => user
  end

  def confirmation_learner(organization, cop, user)
    from 'cop@unglobalcompact.org'
    subject "UN Global Compact Status - 12 Month Learner Grace Period"
    content_type "text/html"
    recipients user.email_recipient
    body :organization => organization, :cop => cop, :user => user
  end

  def confirmation_active(organization, cop, user)
    from 'cop@unglobalcompact.org'
    subject "UN Global Compact Status - GC Active"
    content_type "text/html"
    recipients user.email_recipient
    body :organization => organization, :cop => cop, :user => user
  end

  def confirmation_advanced(organization, cop, user)
    from 'cop@unglobalcompact.org'
    subject "UN Global Compact Status - GC Advanced"
    content_type "text/html"
    recipients user.email_recipient
    body :organization => organization, :cop => cop, :user => user
  end

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
