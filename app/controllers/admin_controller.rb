class AdminController < ApplicationController
  layout 'admin'
  helper 'Admin'

  before_filter :login_required
  before_filter :redirect_non_approved_organizations, :only => :dashboard
  before_filter :add_admin_js
  
  def dashboard
    if current_user.from_ungc?
      pending_states = [Organization::STATE_PENDING_REVIEW, Organization::STATE_IN_REVIEW]
      @pending_organizations = Organization.all(:conditions => ['state in (?)', pending_states],
                                                :limit      => 10,
                                                :order      => 'updated_at DESC')
      @pending_logo_requests = LogoRequest.all(:conditions => ['state in (?)', pending_states],
                                               :limit      => 10,
                                               :order      => 'updated_at DESC')
      @pending_case_stories = CaseStory.all(:conditions => ['state in (?)', pending_states],
                                            :limit      => 10,
                                            :order      => 'updated_at DESC')
      @pending_cops = CommunicationOnProgress.all(:conditions => ['state in (?)', pending_states],
                                                  :limit      => 10,
                                                  :order      => 'updated_at DESC')
      @pending_pages = Page.with_approval('pending').all(:order => 'updated_at DESC')
    elsif current_user.from_network?
      @organizations = Organization.visible_to(current_user)
    elsif current_user.from_organization?
      @organization = current_user.organization
    end      
    render :template => "admin/dashboard_#{current_user.user_type}.html.haml"
  end
  
  # Denies access to a resource if the user belongs to a not yet approved organization 
  def no_unapproved_organizations_access
    if current_user.from_organization? and !current_user.organization.approved?
      redirect_to admin_organization_path current_user.organization.id
    end
  end

  # Denies access to a resource if the user belongs to organization or local network
  def no_organization_or_local_network_access
    redirect_to admin_organization_path(current_user.organization.id) unless current_user.from_ungc?
  end

  private
    def require_staff # TODO: Make this secure
      current_user.from_ungc?
    end
  
    def add_admin_js
      (@javascript ||= []) << 'admin'
    end
    
    def redirect_non_approved_organizations
      if current_user.from_organization? and !current_user.organization.approved?
        redirect_to admin_organization_path current_user.organization.id
      end
    end
end