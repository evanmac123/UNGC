class SessionsController < Devise::SessionsController
  layout 'admin'
  helper AdminHelper
  before_filter :redirect_user_to_dashboard, :only => :new

  protected

  # Forward logged-in users to dashboard
  def redirect_user_to_dashboard
    redirect_to dashboard_path if current_contact
  end
end
