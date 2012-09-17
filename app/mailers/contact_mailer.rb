class ContactMailer < ActionMailer::Base
  default :from => EMAIL_SENDER

  def reset_password(contact)
    @contact = contact
    mail(:to => contact.email_recipient, :subject => "United Nations Global Compact - Reset Password")
  end
end
