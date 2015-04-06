class Redesign::StaticController < Redesign::ApplicationController
  def home
    set_current_container :home
    @page = HomePage.new(current_container, current_payload_data)
  end

  def landing
    set_current_container :landing, '/participation'
    @page = LandingPage.new(current_container, current_payload_data)
  end

  def highlight
    @page = FakeHighlightPage.new
  end

  def article
    set_current_container :article, '/about'
    @page = ArticlePage.new(current_container, current_payload_data)
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
