require 'test_helper'

class Admin::CountriesControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    @country = create_country

    sign_in @staff_user
  end

  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:countries)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create country" do
    assert_difference('Country.count') do
      post :create, :country => { :name => 'country #3',
                                  :code => 'C3',
                                  :region => "MENA" }
    end

    assert_redirected_to admin_countries_path
  end

  test "should get edit" do
    get :edit, :id => @country.to_param
    assert_response :success
  end

  test "should update country" do
    put :update, :id => @country.to_param, :country => { }
    assert_redirected_to admin_countries_path
  end

  test "should destroy country" do
    assert_difference('Country.count', -1) do
      delete :destroy, :id => @country.to_param
    end

    assert_redirected_to admin_countries_path
  end
end
