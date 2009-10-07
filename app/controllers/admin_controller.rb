class AdminController < ApplicationController
  layout 'admin'
  # TODO use a single before_filter
  before_filter :require_staff
  
  before_filter :login_required, :only => :dashboard
  
  def dashboard
    if current_user.from_ungc?
      @pending_organizations = Organization.pending_review.all(:limit => 10)
      @in_review_organizations = Organization.in_review.all(:limit => 10)
      @pending_logo_requests = LogoRequest.pending_review.all(:limit => 10)
      @unreplied_logo_requests = LogoRequest.unreplied.all(:limit => 10)
      @pending_case_stories = CaseStory.pending_review.all(:limit => 10)
    end
    render :template => "admin/dashboard_#{current_user.user_type}.html.haml"
  end
  
  private
  def require_staff # TODO: Make this secure
    true
  end
end