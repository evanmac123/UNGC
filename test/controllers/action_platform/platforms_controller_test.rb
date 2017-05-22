require "test_helper"

class ActionPlatform::PlatformsControllerTest < ActionController::TestCase

  test "#show" do
    platform = create(:action_platform_platform)
    get :show, id: platform

    assert_response :ok
    assert_not_nil assigns(:page)
  end

end
