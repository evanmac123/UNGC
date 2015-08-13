class StaticController < ApplicationController
  def home
    set_current_container :home
    @page = HomePage.new(current_container, current_payload_data)
  end

  def layout_sample
    render layout: 'sample'
    @is_sample_layout = true
  end

  def catch_all
    render_container_at(params[:path])
  end

  def redirect_to_page
    if params[:page]
      redirect_to params[:page], status: :moved_permanently
    else
      redirect_to root_path
    end
  end

end
