# frozen_string_literal: true

module Academy
  class ViewerInvitationJob < ApplicationJob

    def perform(contact)
      token = nil
      Contact.transaction do
        contact.generate_username
        token = contact.send(:set_reset_password_token)
        contact.roles << Role.academy_viewer

        # We're updating potentially very old contacts
        # That may no longer pass validation. skip it.
        contact.save!(validate: false)
      end

      Academy::Mailer.welcome_contact_with_generated_login(contact, token).deliver_now
    end

  end
end
