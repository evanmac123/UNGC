class SessionsController < Devise::SessionsController
  layout 'admin'
  helper 'Admin'
  before_filter :redirect_user_to_dashboard, :only => :new

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Sorry, either your username or password was incorrect. Please click 'Forgot your username or password?' to retrieve your username and choose a new password."
    logger.warn "Failed login for '#{params[:username]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  # Forward logged-in users to dashboard
  def redirect_user_to_dashboard
    redirect_to dashboard_path if current_contact
  end
end
