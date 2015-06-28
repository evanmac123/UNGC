class Redesign::StaticController < Redesign::ApplicationController
  def home
    set_current_container :home
    @page = HomePage.new(current_container, current_payload_data)
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

    render_default_template(current_container.layout)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_to_page
    if params[:page]
      redirect_to params[:page], status: :moved_permanently
    else
      redirect_to root_path
    end
  end

  private

  def render_default_template(layout)
    if lookup_context.find_all(layout).any?
      render(layout.to_sym)
    else
      render_404
    end
  end

  def render_404
    render '/redesign/static/not_found', status: 404
  end

end
