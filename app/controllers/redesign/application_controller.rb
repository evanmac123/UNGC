class Redesign::ApplicationController < ApplicationController
  helper_method \
    :current_container,
    :current_payload,
    :current_payload_data

  before_action :authenticate_contact!
  before_action :only_ungc_contacts!

  protected

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
    @current_container = Redesign::Container.by_path(path).first!
  end

  def set_current_container(layout, slug = '/')
    @current_container = Redesign::Container.lookup(layout, slug)
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
end