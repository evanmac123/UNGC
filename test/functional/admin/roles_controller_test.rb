require 'test_helper'

class Admin::RolesControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    @role = create_role(:name => 'Staff', :description => 'Describes the role')
    
    login_as @staff_user
  end
  
  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:roles)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create role" do
    assert_difference('Role.count') do
      post :create, :role => { :name => 'role #3', :description => 'Describes the role'}
    end

    assert_redirected_to admin_roles_path
  end

  test "should get edit" do
    get :edit, :id => @role.to_param
    assert_response :success
  end

  test "should update role" do
    put :update, :id => @role.to_param, :role => { }
    assert_redirected_to admin_roles_path
  end

  test "should destroy role" do
    assert_difference('Role.count', -1) do
      delete :destroy, :id => @role.to_param
    end

    assert_redirected_to admin_roles_path
  end
end
