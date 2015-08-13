class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :mailer_set_url_options

  helper :datetime

  helper_method \
    :current_container,
    :current_payload,
    :current_payload_data

  rescue_from ActiveRecord::RecordNotFound, :with => :catch_all
  rescue_from ThinkingSphinx::ConnectionError, with: :search_offline

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

  def page_for_container(container)
    "#{container.layout}_page".classify.constantize
  end

  def current_container
    @current_container
  end

  def set_current_container_by_path(path)
    @current_container = begin
      Container.by_path(path).first!
    rescue ActiveRecord::StatementInvalid
      raise ActiveRecord::RecordNotFound
    end
  end

  def set_current_container(layout, slug = '/')
    @current_container = Container.lookup(layout, slug)
  end

  def set_current_container_by_default_path
    set_current_container_by_path(request.path)
  end

  def current_payload
    return unless @current_container

    @current_payload ||= if draft?
      @current_container.draft_payload
    elsif defined_payload?
      @current_container.payloads.find(params[:payload])
    else
      @current_container.public_payload
    end
  end

  def current_payload_data
    @current_payload_data ||= current_payload.try(:data)
  end

  def draft?
    staff? && params[:draft]
  end

  def defined_payload?
    staff? && params[:payload]
  end

  def staff?
    current_contact.present? && current_contact.from_ungc?
  end

  def search_offline
    @page = SearchOfflinePage.new
    render :template => '/redesign/search/offline' and return false
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
