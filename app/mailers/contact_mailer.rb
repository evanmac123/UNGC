class ContactMailer < Devise::Mailer
  default :from => UNGC::Application::EMAIL_SENDER

  def reset_password_instructions(contact)
    @contact = contact
    mail(:to => contact.email_recipient, :subject => "United Nations Global Compact - Reset Password")
  end
end
