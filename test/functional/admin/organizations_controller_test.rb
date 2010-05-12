require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase
  def setup
    @user = create_organization_and_user
    create_staff_user
    create_local_network_with_report_recipient
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
      post :create, {:organization => {:name                 => 'Unspace',
                                       :organization_type_id => OrganizationType.first.id,
                                       :employees            => 500,
                                       :country_id           => @country.id}}, as(@user)
    end

    assert_redirected_to admin_organization_path(assigns(:organization).id)
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
    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end

  test "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, {:id => @organization.to_param}, as(@user)
    end

    assert_redirected_to admin_organizations_path
  end

  test "should list approved organizations" do
    get :approved, {}, as(@user)
    assert_response :success
  end

  test "should list pending organizations" do
    get :pending_review, {}, as(@user)
    assert_response :success
  end

  test "should list network review organizations" do
    get :network_review, {}, as(@user)
    assert_response :success
  end

  test "should list rejected organizations" do
    get :rejected, {}, as(@user)
    assert_response :success
  end
  
  context "given a rejected organization" do
     setup do
       @organization.reject
     end

     should "applicant should not be able to edit" do
       login_as @user
       get :edit, {:id => @organization.id}, as(@user)
       assert_equal "We're sorry, your organization's application was not approved. No edits or comments can be made.", flash[:error]
       assert_redirected_to admin_organization_path(@user.organization.id)
     end

     should "staff should still be able to edit" do
       login_as @staff_user
       get :edit, {:id => @organization.id}, as(@staff_user)
       assert_response :success
     end
   end

end
