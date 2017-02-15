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
    if ensure_has_a_comment(logo_request)
      @logo_request = logo_request
      mail \
        :to => logo_request.contact.email_recipient,
        :subject => "Your Global Compact Logo Request has been accepted"
      else
        raise "LogoRequestMailer requires a logo request to have at least one comment"
    end
  end

  def rejected(logo_request)
    contact = logo_request.contact
    return if contact.nil?

    if ensure_has_a_comment(logo_request)
      @logo_request = logo_request
      mail \
        :to => contact.email_recipient,
        :subject => "Global Compact Logo Request Status"
    else
      raise "LogoRequestMailer requires a logo request to have at least one comment"
    end
  end

  private

  def ensure_has_a_comment(logo_request)
    logo_request.logo_comments.present?
  end

end
