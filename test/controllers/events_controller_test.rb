require 'test_helper'

class EventsControllerTest < ActionController::TestCase

  test "#show" do
    event = create_event
    get :show, permalink: event
  end

end
