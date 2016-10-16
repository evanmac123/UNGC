class Admin::RegistrationsController < Devise::RegistrationsController

  def update
    super do |contact|
      # remember the last password update

      if contact.previous_changes.key? :encrypted_password
        # update last_password_changed_at *without* causing a validation
        # See https://github.com/plataformatec/devise/issues/3499
        contact.update_attribute(:last_password_changed_at, Time.now)
      end
    end
  end

  protected

  def after_update_path_for(contact)
    stored_location_for(:contact) || '/admin'
  end

end
