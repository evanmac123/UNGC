require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
  end
end
