class ContactMailer < Devise::Mailer
  default from: UNGC::Application::EMAIL_SENDER

  # opts={} required by Devise
  def reset_password_instructions(record, token, opts={})
    @token = token
    devise_mail(record, :reset_password_instructions, opts.merge(
      to: record.email_recipient,
      subject: 'United Nations Global Compact - Reset Password'
    ))
  end
end
