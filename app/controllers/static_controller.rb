class StaticController < ApplicationController
  def home
    respond_to do |format|
      format.html {
        set_current_container :home
        @page = HomePage.new(current_container, current_payload_data)
      }
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
