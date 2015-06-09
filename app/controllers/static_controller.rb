class StaticController < ApplicationController
  def home
    set_current_container :home
    if stale?(last_modified: current_container.updated_at.utc, etag: current_container.cache_key)
      @page = HomePage.new(current_container, current_payload_data)
    end
  end

  def layout_sample
    render layout: 'sample'
    @is_sample_layout = true
  end

  def catch_all
    render_container_at(params[:path])
  end
end
