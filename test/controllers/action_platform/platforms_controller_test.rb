require "test_helper"

class ActionPlatform::PlatformsControllerTest < ActionController::TestCase

  test "#show" do
    # Given a platform and a page for it
    platform = create(:action_platform_platform)
    create(:container,
      layout: :action_detail,
      path: "/take-action/action-platforms/#{platform.slug}")

    get :show, slug: platform.slug

    assert_response :ok
    assert_not_nil assigns(:page)
  end

end
