class Redesign::ApplicationController < ApplicationController
  helper_method \
    :current_container,
    :current_payload,
    :current_payload_data

  rescue_from ActiveRecord::RecordNotFound, :with => :catch_all

  rescue_from ThinkingSphinx::ConnectionError, with: :search_offline

  def catch_all
    path = request.path.sub(/^\/redesign/, '')
    set_current_container_by_path(path)

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render("/redesign/static/" + current_container.layout)
  rescue ActiveRecord::RecordNotFound
    render '/redesign/static/not_found', status: 404
  end

  protected

  def page_for_container(container)
    "#{container.layout}_page".classify.constantize
  end

  # TODO remove this on launch
  def only_ungc_contacts!
    unless current_contact.from_ungc?
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end

  def current_container
    @current_container
  end

  def set_current_container_by_path(path)
    @current_container = begin
      Redesign::Container.by_path(path).first!
    rescue ActiveRecord::StatementInvalid
      raise ActiveRecord::RecordNotFound
    end
  end

  def set_current_container(layout, slug = '/')
    @current_container = Redesign::Container.lookup(layout, slug)
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
    render :template => '/redesign/search/offline' and return false
  end
end
