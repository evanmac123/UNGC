class Redesign::StaticController < Redesign::ApplicationController
  def home
    set_current_container :home
    @page = HomePage.new(current_container, current_payload_data)
  end

  def landing
    #set_current_container :landing
    @page = FakeLandingPage.new
  end

  def highlight
    @page = FakeHighlightPage.new
  end

  def article
    set_current_container :article, '/about'
    @page = ArticlePage.new(current_container, current_payload_data)
  end
end
