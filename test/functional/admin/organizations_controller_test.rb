require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase
  def setup
    @user = create_organization_and_user
  end
  
  test "should get index" do
    get :index, {}, as(@user)
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "should get new" do
    get :new, {}, as(@user)
    assert_response :success
  end

  test "should create organization" do
    assert_difference('Organization.count') do
      post :create, {:organization => { :name                 => 'Unspace Interactive',
                                       :organization_type_id => OrganizationType.first.id,
                                       :employees            => 500}}, as(@user)
    end

    assert_redirected_to admin_organization_path(assigns(:organization))
  end

  test "should show organization" do
    get :show, {:id => @organization.to_param}, as(@user)
    assert_response :success
  end

  test "should get edit" do
    get :edit, {:id => @organization.to_param}, as(@user)
    assert_response :success
  end

  test "should update organization" do
    put :update, {:id => @organization.to_param, :organization => { }}, as(@user)
    assert_redirected_to admin_organization_path(assigns(:organization))
  end

  test "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, {:id => @organization.to_param}, as(@user)
    end

    assert_redirected_to admin_organizations_path
  end

  test "should approve pending organization" do
    organization = create_organization(:state => 'pending_review')
    post :approve, {:id => organization.to_param}, as(@user)
    assert_redirected_to admin_organization_path(organization)
    assert organization.reload.approved?
  end

  test "should reject pending organization" do
    organization = create_organization(:state => 'pending_review')
    post :reject, {:id => organization.to_param}, as(@user)
    assert_redirected_to admin_organization_path(organization)
    assert organization.reload.rejected?
  end

  test "should list approved organizations" do
    get :approved, {}, as(@user)
    assert_response :success
  end

  test "should list pending organizations" do
    get :pending_review, {}, as(@user)
    assert_response :success
  end

  test "should list rejected organizations" do
    get :rejected, {}, as(@user)
    assert_response :success
  end
end
