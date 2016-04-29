class SdgPioneerMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper

  def nomination_submitted(nomination_id)
    @nomination = SdgPioneer::Other.find(nomination_id)

    mail to: 'sdgpioneers@unglobalcompact.org',
         subject: 'A SDG Pioneer nomination was received'
  end

  def email_nominee(nomination_id)
    nomination = SdgPioneer::Other.find(nomination_id)
    @nominee = sanitize(nomination.nominee_name)

    mail \
      to:       nomination.nominee_email,
      bcc:      'sdgpioneers@unglobalcompact.org',
      subject:  "Local SDG Pioneer Nomination from the United Nations Global Compact"
  end

  private

  def sanitize(name)
    strip_tags(name)
  end

end
