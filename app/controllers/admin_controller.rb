class AdminController < ApplicationController
  layout 'admin'
  before_filter :require_staff
  
  def dashboard
    if current_user.from_ungc?
      @pending_logo_requests = LogoRequest.pending_review
    end
    render :template => "admin/dashboard_#{current_user.user_type}.html.haml"
  end
  
  private
  def require_staff # TODO: Make this secure
    true
  end
end