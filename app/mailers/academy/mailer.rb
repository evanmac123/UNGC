module Academy
  class Mailer < ActionMailer::Base

    def welcome_new_user(contact, reset_password_token)
      @contact = contact
      @reset_password_token = reset_password_token

      mail \
        to: contact.email_address,
        from: UNGC::Application::EMAIL_SENDER,
        subject: "Welcome to the UN Global Compact Academy"
    end

  end
end
