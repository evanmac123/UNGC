class Admin::RegistrationsController < Devise::RegistrationsController

  def edit
    if incorrectly_refered_to_change_password?
      redirect_to admin_url
    else
      super
    end
  end

  def update
    super do |contact|
      # remember the last password update

      if contact.previous_changes.key? :encrypted_password
        # update last_password_changed_at *without* causing a validation
        # See https://github.com/plataformatec/devise/issues/3499
        contact.update_attribute(:last_password_changed_at, Time.current)
      end
    end
  end

  protected

  def after_update_path_for(contact)
    stored_location_for(:contact) || admin_url
  end

  def incorrectly_refered_to_change_password?
    current_contact.present? &&
      !current_contact.needs_to_change_password?
  end

end
