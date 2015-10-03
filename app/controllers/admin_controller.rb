class AdminController < ApplicationController
  layout 'admin'
  helper 'Admin', 'Admin/Contacts', 'Admin/Organizations', 'Admin/LocalNetworks'
  helper_method :contact_path, :contact_parent_path, :network_management_tab?, :knowledge_sharing_tab?

  before_filter :authenticate_contact!
  before_filter :redirect_non_approved_organizations, :only => :dashboard

  def dashboard
    if current_contact.from_ungc?
      pending_states = [Organization::STATE_PENDING_REVIEW, Organization::STATE_IN_REVIEW]
      @pending_organizations = Organization.where('state in (?)', pending_states)
        .paginate(page: params[:organizations_page])
        .order('updated_at DESC')
      @pending_logo_requests = LogoRequest.where('state in (?)', pending_states)
        .includes(:organization)
        .paginate(page: params[:logo_requests_page])
        .order('updated_at DESC')
      @pending_cops = CommunicationOnProgress.for_feed.paginate(page: params[:cops_page])
    elsif current_contact.from_network? || current_contact.from_regional_center?
      @local_network = current_contact.local_network
      @organizations = Organization.visible_to(current_contact)
      @announcements = Announcement.upcoming
      @contact_points = sign_in_as_contacts

    elsif current_contact.from_organization?
      @organization = current_contact.organization

    end
    render :template => "admin/dashboard_#{current_contact.user_type}"
  end

  def no_access_to_other_organizations
    if current_contact.from_organization? and current_contact.organization != @organization
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end

  def no_access_to_other_local_networks
    if (current_contact.from_network? and current_contact.local_network != @local_network) || current_contact.from_organization?
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end

  # Denies access if the user belongs to a rejected organization
  def no_rejected_organizations_access
    if current_contact.organization.rejected? and !current_contact.from_ungc?
      flash[:error] = "We're sorry, your organization's application was not approved. No edits or comments can be made."
      redirect_to admin_organization_path current_contact.organization.id
    end
  end

  # Denies access to a resource if the user belongs to a not yet approved organization
  def no_unapproved_organizations_access
    if current_contact.from_organization? and !current_contact.organization.approved?
      redirect_to admin_organization_path current_contact.organization.id
    end
  end

  # Denies access to a resource if the user belongs to an approved organization
  def no_approved_organizations_access
    if current_contact.from_organization? and current_contact.organization.approved?
      flash[:notice] = "Your organization's application was approved. Comments are no longer being accepted."
      redirect_to admin_organization_path current_contact.organization.id
    end
  end

  # Denies access to a resource if the user belongs to organization or local network
  def no_organization_or_local_network_access
    unless current_contact.from_ungc?
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end

  private

  def contact_path(contact, params={})
    contact_parent_path(contact, ["contact"], [contact], params)
  end

  def contact_parent_path(contact, components=[], arguments=[], params={})
    params = params.with_indifferent_access

    components = [components].flatten
    arguments  = [arguments].flatten

    if contact.organization_id?
      components.unshift("organization")
      arguments.unshift(contact.organization_id)
    elsif contact.local_network_id?
      components.unshift("local_network")
      arguments.unshift(contact.local_network_id)
    else
      raise ArgumentError, "Contact is from neither an organization nor a network"
    end

    components.unshift("admin")

    if action = params.delete(:action)
      components.unshift(action)
    end

    components.push("path")
    arguments.push(params)

    method_name = components.join("_")
    send(method_name, *arguments)
  end

  def redirect_non_approved_organizations
    if current_contact.from_organization? and !current_contact.organization.approved?
      redirect_to admin_organization_path current_contact.organization.id
    end
  end

  def network_management_tab?
    false
  end

  def knowledge_sharing_tab?
    false
  end

  def sign_in_policy
    @sign_in_policy ||= SignInPolicy.new(current_contact)
  end

  def sign_in_as_contacts
    sign_in_policy.sign_in_targets(from: @organizations).paginate(
      page: params[:contact_points_page],
      per_page: 100
    )
  end

end
