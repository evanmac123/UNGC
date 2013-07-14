class Admin::PasswordsController < Devise::PasswordsController
  layout 'admin'
  helper 'Admin'

  def create
    self.resource = resource_class.find_by_email(resource_params[:email])

    if resource && resource.username.present?
      resource_class.send_reset_password_instructions(resource_params)
      if successfully_sent?(resource)
        flash[:notice] = 'Thank you. We have sent you an email with instructions on resetting your password.'
        respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
      else
        flash[:notice] = 'Sorry, we could not send the email due to a server error. Please try again.'
        respond_with(resource, :location => new_password_path(resource))
      end
    else
      flash.now[:error] = "Sorry, we could not find a username with the email you provided."
      render :action => 'new'
    end

  rescue => e
    flash[:notice] = 'Sorry, we could not send the email due to a server error. Please try again.'
    redirect_to new_password_path(resource)
  end

end
