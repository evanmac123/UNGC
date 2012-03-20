require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase
  def setup
    @user = create_organization_and_user
    create_staff_user
    create_local_network_with_report_recipient
  end

  test "should get index" do
    get :index, {}, as(@staff_user)
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "should get new" do
    get :new, {}, as(@staff_user)
    assert_response :success
    assert_template :partial => '_new_signatory'
  end

  test "should create organization" do
    assert_difference('Organization.count') do
      post :create, {:organization => {:name                 => 'Unspace',
                                       :organization_type_id => OrganizationType.first.id,
                                       :employees            => 500,
                                       :country_id           => @country.id}}, as(@staff_user)
    end

    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end

  test "should show organization" do
    get :show, {:id => @organization.to_param}, as(@user)
    assert_response :success
  end

  test "should not show other organizations to user" do
    @organization = Organization.create(:name                 => 'SME',
                                        :employees            => 50,
                                        :organization_type_id => OrganizationType.first.id)
    login_as @user
    get :show, {:id => @organization.to_param}, as(@user)
    assert_redirected_to dashboard_path
    assert_equal "You do not have permission to access that resource.", flash[:error]
  end

  test "should get edit" do
    get :edit, {:id => @organization.to_param}, as(@staff_user)
    assert_response :success
  end

  test "staff should update organization and redirect to organization show view" do
    put :update, {:id => @organization.to_param, :organization => { }}, as(@staff_user)
    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end

  test "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, {:id => @organization.to_param}, as(@user)
    end

    assert_redirected_to admin_organizations_path
  end

  test "should list approved organizations" do
    get :approved, {}, as(@staff_user)
    assert_response :success
  end

  test "should list pending organizations" do
    get :pending_review, {}, as(@staff_user)
    assert_response :success
  end

  test "should list updated organizations" do
    get :updated, {}, as(@staff_user)
    assert_response :success
  end

  test "should list network review organizations" do
    get :network_review, {}, as(@staff_user)
    assert_response :success
  end

  test "should list rejected organizations" do
    get :rejected, {}, as(@staff_user)
    assert_response :success
  end

  test "should list organizations in review" do
    get :in_review, {}, as(@staff_user)
    assert_response :success
  end

  test "should redirect participants to main dashboard after updating" do
    login_as @user
    put :update, {:id => @organization.to_param, :organization => { }}, as(@user)
    assert_redirected_to dashboard_path
  end


  context "given an organization in review" do
    setup do
      @organization.state = Organization::STATE_IN_REVIEW
    end

    should "should set replied_to to false after a user updates" do
      login_as @user
      put :update, {:id => @organization.to_param, :organization => { }}, as(@user)
      @organization.reload
      assert_equal false, @organization.replied_to
      assert_redirected_to dashboard_path
    end

    should "should set replied_to to true after a staff user updates" do
      login_as @staff_user
      put :update, {:id => @organization.to_param, :organization => { }}, as(@staff_user)
      @organization.reload
      assert_equal true, @organization.replied_to
      assert_redirected_to admin_organization_path(@organization.id)
    end

    should "not reverse roles without one CEO and Contact Point" do
      login_as @staff_user
      get :reverse_roles, {:id => @organization.to_param}
      assert_equal 'Sorry, the roles could not be reversed. There can only be one Contact Point and one CEO to reverse roles.', flash[:error]
      assert_redirected_to admin_organization_path(@organization.id)
    end

    should "reverse roles" do
      create_organization_and_ceo
      login_as @staff_user
      get :reverse_roles, {:id => @organization.to_param}
      assert_equal 'The CEO and Contact Point roles were reversed.', flash[:notice]
      assert_redirected_to admin_organization_path(@organization.id)
    end

    should "be able to edit Letter of Commitment" do
      login_as @user
      get :edit, {:id => @organization.to_param}, as(@staff_user)
      assert_select "input#organization_commitment_letter"
    end

    should "staff should see the fieldset for selecting why they are in review" do
      # login_as @staff_user
      # get :edit, {:id => @organization.to_param}, as(@staff_user)
      # assert_select "fieldset#review_reason"
    end

  end

  context "given an approved organization" do
    setup do
      @organization.approve
    end

    should "user should not see upload field for commitment letter" do
      login_as @user
      get :edit, {:id => @organization.to_param}, as(@user)
      assert_select "input#organization_commitment_letter", 0
    end
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

   context "given an expelled company" do
     setup do
       create_expelled_organization
     end

     should "not be able to submit a COP" do
       login_as @organization_user
       get :show, {:id => @organization.to_param}, as(@organization_user)
       # TODO need to check that the "New Communication on Progress" button is not displayed
       assert_response :success
       assert_select 'div' do
         assert_select 'div', 1
       end
     end

   end

end
