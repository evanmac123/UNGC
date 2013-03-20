class LogoRequestMailer < ActionMailer::Base
  default :from => 'logorequests@unglobalcompact.org',
          :bcc  => 'archive@unglobalcompact.org'

  def in_review(logo_request)
    @logo_request = logo_request
    mail \
      :to => logo_request.contact.email_recipient,
      :subject => "Your Global Compact Logo Request has been updated"
  end

  def approved(logo_request)
    @logo_request = logo_request
    mail \
      :to => logo_request.contact.email_recipient,
      :subject => "Your Global Compact Logo Request has been accepted"
  end

  def rejected(logo_request)
    @logo_request = logo_request
    mail \
      :to => logo_request.contact.email_recipient,
      :subject => "Global Compact Logo Request Status"
  end
end
