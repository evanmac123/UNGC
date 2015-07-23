require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase
  setup do
    create_container path: '/what-is-gc/participants'

    create_organization_and_user

    @participant = Organization.last
  end

  test "should get show" do
    get :show, id: @participant

    assert_response :success
    assert_not_nil assigns(:page)
  end
end
