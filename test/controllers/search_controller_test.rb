require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test 'should get search' do
    get :search
    assert_response :success
    assert_not_nil assigns(:search)
    assert_not_nil assigns(:results)
    assert_not_nil assigns(:page)
  end
end
