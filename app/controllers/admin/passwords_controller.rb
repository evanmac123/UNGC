class Admin::PasswordsController < ApplicationController
  layout 'admin'
  helper 'Admin'
  
  def create
    @contact = Contact.with_login.find_by_email params[:email]
    if @contact
      @contact.refresh_reset_password_token!
      ContactMailer.deliver_reset_password(@contact)
      flash.now[:notice] = 'Thank you. We have sent you an email with instructions on resetting your password.'
    else
      flash.now[:error] = "Sorry, we could not find a username with the email you provided."
    end
    render :action => 'new'
  end
  
  def edit
    @contact = Contact.find_by_reset_password_token params[:id]
    unless @contact
      flash[:error] = "Your password reset request has expired. Please re-enter your email to reset your password."
      redirect_to new_password_path
    end
  end
  
  def update
    @contact = Contact.find_by_reset_password_token params[:id]
    errors = validate_new_password
    if errors.empty?
      @contact.password = params[:password]
      @contact.save
      flash[:notice] = "Your password was successfully changed."
      redirect_to login_path
    else
      flash.now[:error] = errors.join(" ")
      render :action => 'edit'
    end
  end
  
  private
    def validate_new_password
      errors = []
      errors << "Make sure the passwords you entered match." if params[:password] != params[:password_confirmation]
      errors << "You cannot use a blank password." if params[:password].blank? || params[:password_confirmation].blank?
      errors
    end
end
