class AdminController < ApplicationController
  layout 'admin'
  # TODO use a single before_filter
  before_filter :login_required #, :only => :dashboard
  # before_filter :require_staff # FIXME: restore something here, that also works for organization members, local network admins, etc.
  before_filter :add_admin_js
  helper 'Admin'
  
  def dashboard
    if current_user.from_ungc?
      @pending_organizations = Organization.pending_review.all(:limit => 10)
      @in_review_organizations = Organization.in_review.all(:limit => 10)
      @pending_logo_requests = LogoRequest.pending_review.all(:limit => 10)
      @unreplied_logo_requests = LogoRequest.unreplied.all(:limit => 10)
      @pending_case_stories = CaseStory.pending_review.all(:limit => 10)
      @pending_cops = CommunicationOnProgress.pending_review.all(:limit => 10)
    elsif current_user.from_network?
      @organizations = Organization.visible_to(current_user)
    elsif current_user.from_organization?
      @organization = current_user.organization
    end
    render :template => "admin/dashboard_#{current_user.user_type}.html.haml"
  end
  
  private
  def require_staff # TODO: Make this secure
    current_user.from_ungc?
  end
  
  def add_admin_js
    (@javascript ||= []) << 'admin'
  end
end