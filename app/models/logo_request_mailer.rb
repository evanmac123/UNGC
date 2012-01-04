class LogoRequestMailer < ActionMailer::Base
  def in_review(logo_request)
    from 'logorequests@unglobalcompact.org'
    bcc 'gclogo@un.org'
    subject "Your Global Compact Logo Request has been updated"
    content_type "text/html"
    recipients logo_request.contact.email_recipient
    body :logo_request => logo_request
  end

  def approved(logo_request)
    from 'logorequests@unglobalcompact.org'
    bcc 'gclogo@un.org'
    subject "Your Global Compact Logo Request has been accepted"
    content_type "text/html"
    recipients logo_request.contact.email_recipient
    body :logo_request => logo_request
  end

  def rejected(logo_request)
    from 'logorequests@unglobalcompact.org'
    bcc 'gclogo@un.org'
    subject "Global Compact Logo Request Status"
    content_type "text/html"
    recipients logo_request.contact.email_recipient
    body :logo_request => logo_request
  end
end
