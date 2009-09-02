require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  def setup
    @organization = create_organization
    @contact = create_contact(:organization_id => @organization.id,
                              :email           => "dude@example.com")
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organization" do
    assert_difference('Organization.count') do
      post :create, :organization => { :name => 'Unspace Interactive' }
    end

    assert_redirected_to organization_path(assigns(:organization))
  end

  test "should show organization" do
    get :show, :id => @organization.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @organization.to_param
    assert_response :success
  end

  test "should update organization" do
    put :update, :id => @organization.to_param, :organization => { }
    assert_redirected_to organization_path(assigns(:organization))
  end

  test "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, :id => @organization.to_param
    end

    assert_redirected_to organizations_path
  end

  test "should approve pending organization" do
    organization = create_organization(:state => 'pending')
    post :approve, :id => organization.to_param
    assert_redirected_to organization
    assert organization.reload.approved?
  end

  test "should reject pending organization" do
    organization = create_organization(:state => 'pending')
    post :reject, :id => organization.to_param
    assert_redirected_to organization
    assert organization.reload.rejected?
  end

  test "should list approved organizations" do
    get :approved
    assert_response :success
  end

  test "should list pending organizations" do
    get :pending
    assert_response :success
  end

  test "should list rejected organizations" do
    get :rejected
    assert_response :success
  end
end
