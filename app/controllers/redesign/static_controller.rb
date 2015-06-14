class Redesign::StaticController < Redesign::ApplicationController
  def home
    set_current_container :home
    @page = HomePage.new(current_container, current_payload_data)
  end

  def not_found
    render :not_found, status: 404
  end

  def layout_sample
    render layout: 'redesign/sample'
    @is_sample_layout = true
  end

  def catch_all
    set_current_container_by_path(params[:path])

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render(current_container.layout.to_sym)
  rescue ActiveRecord::RecordNotFound
    redirect_to redesign_not_found_path
  end

  def redirect_to_page
    if params[:page]
      redirect_to params[:page], status: :moved_permanently
    else
      redirect_to root_path
    end
  end
end
