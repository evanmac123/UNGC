# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :mailer_set_url_options

  helper 'datetime'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Override Devise Settings
  def after_sign_in_path_for(contact)
    if contact.from_rejected_organization?
      sign_out contact
      flash[:notice] = nil
      flash[:error] = "Sorry, your organization's application was rejected and can no longer be accessed."
      new_contact_session_path
    else
      redirect_path = edit_or_dashboard_path(contact)
      back_or_default_path(redirect_path)
    end
  end

  def after_sign_out_path_for(contact)
    new_contact_session_path
  end

  def back_or_default_path(default)
    stored_location_for(:contact) || default
  end

  def edit_or_dashboard_path(contact)
    if @update_contact_info
      edit_admin_organization_contact_path(contact.organization.id, contact, {:update => true})
    else
      dashboard_path
    end
  end

  protected

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
