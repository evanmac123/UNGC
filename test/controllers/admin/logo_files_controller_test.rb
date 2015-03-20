require 'test_helper'

class Admin::LogoFilesControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    @logo_file = create_logo_file

    sign_in @staff_user
  end

  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:logo_files)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create logo file" do
    assert_difference('LogoFile.count') do
      post :create, :logo_file => { :name      => 'logo file #3',
                                    :thumbnail => 'blah.png'}
    end

    assert_redirected_to admin_logo_files_path
  end

  test "should get edit" do
    get :edit, :id => @logo_file.to_param
    assert_response :success
  end

  test "should update logo file" do
    put :update, :id => @logo_file.to_param, :logo_file => { }
    assert_redirected_to admin_logo_files_path
  end

  test "should destroy logo file" do
    assert_difference('LogoFile.count', -1) do
      delete :destroy, :id => @logo_file.to_param
    end

    assert_redirected_to admin_logo_files_path
  end
end
