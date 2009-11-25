class ContactMailer < ActionMailer::Base
  def reset_password(contact)
    subject "Reset Your Password"
    from EMAIL_SENDER
    content_type "text/html"
    recipients contact.email
    body :contact => contact
  end
end
