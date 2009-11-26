class Admin::PasswordsController < ApplicationController
  layout 'admin'
  helper 'Admin'
  
  def create
    @contact = Contact.with_login.find_by_email params[:email]
    if @contact
      @contact.refresh_reset_password_token!
      ContactMailer.deliver_reset_password(@contact)
      flash.now[:notice] = 'We sent you an email to help you reset your password.'
    else
      flash.now[:error] = "We couldn't find a user with the email you provided."
    end
    render :action => 'new'
  end
  
  def edit
    @contact = Contact.find_by_reset_password_token params[:id]
    unless @contact
      flash[:error] = "Please, request a new email to reset your password"
      redirect_to new_password_path
    end
  end
  
  def update
    @contact = Contact.find_by_reset_password_token params[:id]
    if params[:password] == params[:password_confirmation]
      @contact.password = params[:password]
      @contact.save
      flash[:notice] = "Your password was successfully changed."
      redirect_to login_path
    else
      flash.now[:error] = "Make sure the passwords you entered match."
      render :action => 'edit'
    end
  end
end
