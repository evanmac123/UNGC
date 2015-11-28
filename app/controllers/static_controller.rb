class StaticController < ApplicationController
  def home
    set_current_container :home
    if cache_stale?
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

  private

  def cache_stale?
    cachable = CompositeCachable.new(current_container, current_payload)
    stale? last_modified: cachable.updated_at, etag: cachable.cache_key
  end

end
