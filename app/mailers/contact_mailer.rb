class ContactMailer < Devise::Mailer
  default :from => UNGC::Application::EMAIL_SENDER

  # opts={} required by Devise
  def reset_password_instructions(contact, opts={})
    @contact = contact
    mail(:to => contact.email_recipient, :subject => "United Nations Global Compact - Reset Password")
  end

end
