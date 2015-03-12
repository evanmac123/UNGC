class Redesign::ApplicationController < ApplicationController
  helper_method \
    :current_container,
    :current_payload,
    :current_payload_data

  protected

  def current_container
    @current_container
  end

  def set_current_container(layout, slug = '/')
    @current_container = Redesign::Container.lookup(layout, slug)
  end

  def current_payload
    return unless @current_container

    @current_payload ||= if params[:draft]
      @current_container.draft_payload
    else
      @current_container.public_payload
    end
  end

  def current_payload_data
    @current_payload_data ||= current_payload.try(:data)
  end
end
