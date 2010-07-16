class AdminController < ApplicationController
  layout 'admin'
  helper 'Admin', 'Admin/Organizations'

  before_filter :login_required
  before_filter :redirect_non_approved_organizations, :only => :dashboard
  before_filter :no_organization_or_local_network_access, :only => :parameters
  before_filter :add_admin_js
  
  def dashboard
    if current_user.from_ungc?
      pending_states = [Organization::STATE_PENDING_REVIEW, Organization::STATE_IN_REVIEW]
      @pending_organizations = Organization.paginate(:conditions => ['state in (?)', pending_states],
                                                     :order      => 'updated_at DESC',
                                                     :page       => params[:organizations_page])
      @pending_logo_requests = LogoRequest.paginate(:conditions => ['state in (?)', pending_states],
                                                    :order      => 'updated_at DESC',
                                                    :page       => params[:logo_requests_page],
                                                    :include    => :organization)
      @pending_case_stories = CaseStory.paginate(:conditions => ['state in (?)', pending_states],
                                                 :order      => 'updated_at DESC',
                                                 :page       => params[:case_stories_page],
                                                 :include    => :organization)
      @pending_cops = CommunicationOnProgress.paginate(:conditions => ['state in (?)', pending_states],
                                                       :order      => 'updated_at DESC',
                                                       :page       => params[:cops_page],
                                                       :include    => :organization)
      @pending_pages = Page.with_approval('pending').paginate(:order => 'updated_at DESC',
                                                              :page  => params[:pages_page])
    elsif current_user.from_network?
      @organizations = Organization.visible_to(current_user)
    elsif current_user.from_organization?
      @organization = current_user.organization
    end      
    render :template => "admin/dashboard_#{current_user.user_type}.html.haml"
  end
  
  def no_access_to_other_organizations
    if current_user.from_organization? and current_user.organization != @organization
      flash[:error] = "You do not have permission to access that resource."
      redirect_to admin_organization_path current_user.organization.id
    end
  end
  
  # Denies access if the user belongs to a rejected organization
  def no_rejected_organizations_access
    if current_user.organization.rejected? and !current_user.from_ungc?
      flash[:error] = "We're sorry, your organization's application was not approved. No edits or comments can be made."
      redirect_to admin_organization_path current_user.organization.id
    end
  end
  
  # Denies access to a resource if the user belongs to a not yet approved organization 
  def no_unapproved_organizations_access
    if current_user.from_organization? and !current_user.organization.approved?
      redirect_to admin_organization_path current_user.organization.id
    end
  end

  # Denies access to a resource if the user belongs to an approved organization 
  def no_approved_organizations_access
    if current_user.from_organization? and current_user.organization.approved?
      flash[:notice] = "Your organization's application was approved. Comments are no longer being accepted."
      redirect_to admin_organization_path current_user.organization.id
    end
  end

  # Denies access to a resource if the user belongs to organization or local network
  def no_organization_or_local_network_access
    redirect_to admin_organization_path(current_user.organization.id) unless current_user.from_ungc?
  end

  private
    def add_admin_js
      (@javascript ||= []) << 'admin'
    end
    
    def redirect_non_approved_organizations
      if current_user.from_organization? and !current_user.organization.approved?
        redirect_to admin_organization_path current_user.organization.id
      end
    end
end