# frozen_string_literal: true

class Contact::Creator

  def initialize(contact, contact_policy)
    @contact = contact
    @contact_policy = contact_policy
  end

  def create
    unless contact_policy.can_create?(contact)
      contact.errors.add(:base, 'You are not authorized to create that contact.')
      return false
    end

    unless contact_policy.can_upload_image?(contact)
      contact.image = nil
    end

    contact.save.tap do |success|
      send_welcome_email_to(contact) if success
    end
  end

  private

  def send_welcome_email_to(contact)
    academy_policy = Academy::SignInPolicy.new

    if contact.from_organization? && contact.username.present? && academy_policy.can_sign_in?(contact)
      token = contact.send(:set_reset_password_token)
      Academy::Mailer.welcome_new_user(contact, token).deliver_later
    end
  end

  attr_reader :contact, :contact_policy

end
