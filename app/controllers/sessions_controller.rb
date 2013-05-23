class SessionsController < Devise::SessionsController
  layout 'admin'
  helper 'Admin'
  before_filter :redirect_user_to_dashboard, :only => :new

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)

    if resource_name == 'contact'
      if resource.from_rejected_organization?
        logout_and_redirect_to_login(resource)
      else
        redirect_path = redirect_to_edit_or_dashboard(resource)
        redirect_back_or_default redirect_path
      end
    else
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
  end

  protected

  def redirect_to_edit_or_dashboard(resource)
    if resource.needs_to_update_contact_info
      edit_admin_organization_contact_path(resource.organization.id, resource, {:update => true})
    else
      dashboard_path
    end
  end

  # Forward logged-in users to dashboard
  def redirect_user_to_dashboard
    redirect_to dashboard_path if current_contact
  end
end
