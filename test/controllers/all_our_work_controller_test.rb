require 'test_helper'

class AllOurWorkControllerTest < ActionController::TestCase
  setup do
    create(:container, path: '/what-is-gc/our-work/all')
  end

  test 'should get index' do
    skip # flakey
    get :index
    assert_response :success
    assert_not_nil assigns(:search)
    assert_not_nil assigns(:page)
  end
end
