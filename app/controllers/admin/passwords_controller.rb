class Admin::PasswordsController < Devise::PasswordsController
  layout 'admin'
  helper 'Admin'

  def create
    super
  rescue Errno::ECONNREFUSED => e
    # TODO: Remove this rescue because it's weird.
    flash[:notice] = 'Sorry, we could not send the email due to a server error. Please try again.'
    redirect_to new_contact_session_url
  end
end
