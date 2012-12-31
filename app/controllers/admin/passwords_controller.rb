class Admin::PasswordsController < DeviseController
  layout 'admin'
  helper 'Admin'

  def create
    email = params[:contact] && params[:contact][:email]
    @contact = Contact.find_by_email(email) unless email.blank?
    if @contact && @contact.username.present?
      begin
        ContactMailer.reset_password_instructions(@contact).deliver
      rescue Exception => e
       flash[:notice] = 'Sorry, we could not send the email due to a server error. Please try again.'
       redirect_to new_password_path
      else
       flash[:notice] = 'Thank you. We have sent you an email with instructions on resetting your password.'
       redirect_to new_contact_session_path
      end

    else
      flash.now[:error] = "Sorry, we could not find a username with the email you provided."
      render :action => 'new'
    end
  end

end
