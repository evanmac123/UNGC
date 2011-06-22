class SessionsController < ApplicationController
  layout 'admin'
  helper 'Admin'
  before_filter :redirect_user_to_dashboard, :only => :new
  after_filter :set_last_login_at, :only => :create
  
  def create
    @user = Contact.authenticate(params[:login], params[:password])
    if @user
      
      self.current_user = @user

      if @user.from_rejected_organization?
        logout_and_redirect_to_login @user
      else
        new_cookie_flag = (params[:remember_me] == "1")
        handle_remember_cookie! new_cookie_flag
        redirect_path = redirect_to_edit_or_dashboard @user
        redirect_back_or_default redirect_path
        flash[:notice] = "Welcome #{@user.first_name}. You have been logged in."
      end

    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
    
  end
  
  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end

  def redirect_to_edit_or_dashboard(user)
    if user.needs_to_update_contact_info
      edit_admin_organization_contact_path(user.organization.id, user, {:update => true})
    else
      dashboard_path
    end
  end
  
  protected
    
    def set_last_login_at
      current_user.set_last_login_at if logged_in?
    end
    
    # Track failed login attempts
    def note_failed_signin
      flash[:error] = "Sorry, either your username or password was incorrect. Please click 'Forgot your username or password?' to retrieve your username and choose a new password."
      logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
    end
    
    # Forward logged-in users to dashboard
    def redirect_user_to_dashboard
      redirect_to dashboard_path if logged_in?
    end
    
    # Forward rejected applicants back to login
    def logout_and_redirect_to_login(user)
      logout_killing_session!
      rejected_date = user.organization.rejected_on.strftime('%e %B, %Y')
      flash[:error] = "Sorry, your organization's application was rejected on #{rejected_date} and can no longer be accessed."
      redirect_to login_path
    end
    
end