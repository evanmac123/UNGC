require 'test_helper'

class Admin::SectorsControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    @sector = create_sector

    sign_in @staff_user
  end

  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:sectors)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create sector" do
    assert_difference('Sector.count') do
      post :create, :sector => { :name => 'sector #3'}
    end

    assert_redirected_to admin_sectors_path
  end

  test "should get edit" do
    get :edit, :id => @sector.to_param
    assert_response :success
  end

  test "should update sector" do
    put :update, :id => @sector.to_param, :sector => { }
    assert_redirected_to admin_sectors_path
  end

  test "should destroy sector" do
    assert_difference('Sector.count', -1) do
      delete :destroy, :id => @sector.to_param
    end

    assert_redirected_to admin_sectors_path
  end
end
