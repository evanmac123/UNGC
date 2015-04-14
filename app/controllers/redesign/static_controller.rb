class Redesign::StaticController < Redesign::ApplicationController
  def home
    set_current_container :home
    @page = HomePage.new(current_container, current_payload_data)
  end

  def issue
    # set_current_container :issue, '/issue'
    @page = FakeIssuePage.new
  end

  def action
    # set_current_container :action, '/action'
    @page = FakeActionPage.new
  end

  def catch_all
    set_current_container_by_path(params[:path])

    @page = page_for_container(current_container).new(
      current_container,
      current_payload_data
    )

    render(current_container.layout.to_sym)
  end

  private

  def page_for_container(container)
    "#{container.layout}_page".classify.constantize
  end
end
