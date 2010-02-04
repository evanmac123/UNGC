require 'test_helper'

class Admin::LocalNetworksControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    @local_network = create_local_network
    
    login_as @staff_user
  end
  
  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:local_networks)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create local network" do
    assert_difference('LocalNetwork.count') do
      post :create, :local_network => { :name => 'Canada'}
    end

    assert_redirected_to admin_local_networks_path
  end

  test "should get edit" do
    get :edit, :id => @local_network.to_param
    assert_response :success
  end

  test "should update local network" do
    put :update, :id => @local_network.to_param, :local_network => { }
    assert_redirected_to admin_local_networks_path
  end

  test "should destroy local network" do
    assert_difference('LocalNetwork.count', -1) do
      delete :destroy, :id => @local_network.to_param
    end

    assert_redirected_to admin_local_networks_path
  end
end
