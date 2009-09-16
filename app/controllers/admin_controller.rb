class AdminController < ApplicationController
  layout 'admin'
  # TODO use a single before_filter
  before_filter :require_staff
  
  before_filter :login_required, :only => :dashboard
  
  def dashboard
    if current_user.from_ungc?
      @pending_logo_requests = LogoRequest.pending_review
      @unreplied_logo_requests = LogoRequest.unreplied
    end
    render :template => "admin/dashboard_#{current_user.user_type}.html.haml"
  end
  
  private
  def require_staff # TODO: Make this secure
    true
  end
end