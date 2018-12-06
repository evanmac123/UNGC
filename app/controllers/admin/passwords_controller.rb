class Admin::PasswordsController < Devise::PasswordsController
  layout 'admin'
  helper AdminHelper

  def create
    super
  rescue Errno::ECONNREFUSED => e
    flash[:notice] = 'Sorry, we could not send the email due to a server error. Please try again.'
    redirect_to new_contact_session_url
  end

  def update
    super do |contact|
      if academy_only_viewer?(contact)
        # Academy viewers that can't login need to be redirected to
        # the academy after resetting their password
        url = "https://academy.unglobalcompact.org/learn"
        respond_with contact, location: url
        break # don't go any further
      end
    end
  end

  private

  def academy_only_viewer?(contact)
    Devise.sign_in_after_reset_password &&
      !contact.active_for_authentication? &&
      contact.is?(Role.academy_viewer)
  end

end
