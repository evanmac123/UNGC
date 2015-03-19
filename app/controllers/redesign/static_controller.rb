class Redesign::StaticController < Redesign::ApplicationController
  def home
    set_current_container :home
    #@page = HomePage.new(current_container, current_payload_data)
    @page = FakeHomePage.new
  end

  def landing
    #set_current_container :landing
    @page = FakeLandingPage.new
  end
end
