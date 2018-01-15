class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :mailer_set_url_options

  around_action :set_time_zone, if: :current_contact

  helper DatetimeHelper

  helper_method \
    :current_container,
    :current_payload,
    :current_payload_data

  rescue_from ActiveRecord::RecordNotFound, :with => :catch_all
  rescue_from ThinkingSphinx::ConnectionError, with: :search_offline

  def catch_all
    render_container_at(request.path)
  end

  def render_container_at(path)
    set_current_container_by_path(path)

    page_class = page_for_container(current_container)
    @page = page_class.new(current_container, current_payload_data)

    render_default_template(current_container.layout)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Override Devise Settings
  def after_sign_in_path_for(contact)
    return_to_path = stored_location_for(:contact) || dashboard_path

    case
    when contact.from_rejected_organization?
      sign_out_reject_organization_contact(contact)
    when contact.needs_to_update_contact_info?
      redirect_to_update_contact_info(contact)
    when contact.needs_to_change_password?
      redirect_to_change_password(return_to_path)
    else
      return_to_path
    end
  end

  def after_sign_out_path_for(contact)
    new_contact_session_path
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

    respond_to do |format|
      format.html {
        render :template => '/search/offline' and return false
      }
      format.atom {
        render status: 500, nothing: true and return false
      }
    end
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def event_store
    Rails.configuration.x_event_store
  end

  private

  def render_default_template(layout)
    if File.exists? layout_template_path(layout)
      render("static/#{layout}")
    else
      render_404
    end
  end

  def render_404
    respond_to do |format|
      format.html { render '/static/not_found', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def layout_template_path(layout)
    # assumes .html and .erb
    Rails.root.join("app", "views", "static", "#{layout}.html.erb")
  end

  def sign_out_reject_organization_contact(contact)
    sign_out contact
    flash[:notice] = nil
    flash[:error] = "Sorry, your organization's application was rejected and can no longer be accessed."
    new_contact_session_path
  end

  def redirect_to_update_contact_info(contact)
    edit_admin_organization_contact_path(contact.organization_id, contact, update: true)
  end

  def redirect_to_change_password(return_to_path)
    session['contact_return_to'] = return_to_path
    edit_contact_registration_path
  end

  def set_time_zone(&block)
    Time.use_zone(current_contact.time_zone, &block)
  end

end
