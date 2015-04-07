require 'test_helper'

class Redesign::Admin::Api::ContainersControllerTest < ActionController::TestCase

  setup do
    create_staff_user
    sign_in @staff_user
  end

  test "a successful publish" do
    ContainerPublisher.any_instance.stubs(:publish).returns(true)

    post :publish, id: create_container
    assert_response :no_content
  end

  test "a failed publish" do
    ContainerPublisher.any_instance.stubs(:publish).returns(false)

    post :publish, id: create_container
    assert_response :bad_request
  end

end
