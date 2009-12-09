class ContactMailer < ActionMailer::Base
  def reset_password(contact)
    subject "United Nations Global Compact - Reset Password"
    from EMAIL_SENDER
    content_type "text/html"
    recipients contact.email_recipient
    body :contact => contact
  end
end
