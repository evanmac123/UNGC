class AdminController < ApplicationController
  layout 'admin'
  # TODO use a single before_filter
  before_filter :login_required #, :only => :dashboard
  before_filter :load_organization, :only => :dashboard
  before_filter :redirect_non_approved_organizations, :only => :dashboard
  # before_filter :require_staff # FIXME: restore something here, that also works for organization members, local network admins, etc.
  before_filter :add_admin_js
  helper 'Admin'
  
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
    
    def redirect_non_approved_organizations
      if current_user.from_organization? and !@organization.approved?
        redirect_to admin_organization_path @organization.id
      end
    end
    
    def load_organization
      if current_user.from_network?
        @organizations = Organization.visible_to(current_user)
      elsif current_user.from_organization?
        @organization = current_user.organization
      end
    end
end