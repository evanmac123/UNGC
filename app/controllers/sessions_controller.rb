class SessionsController < Devise::SessionsController
  layout 'admin'
  helper 'Admin'
  before_filter :redirect_user_to_dashboard, :only => :new
  prepend_before_filter :check_contact, :only => :create

  protected

  def check_contact
    return unless resource_name == :contact && params[:contact]

    if contact = Contact.find_by_username(params[:contact][:username])
      @update_contact_info = contact.needs_to_update_contact_info?
    end
  end

  # Forward logged-in users to dashboard
  def redirect_user_to_dashboard
    redirect_to dashboard_path if current_contact
  end
end
