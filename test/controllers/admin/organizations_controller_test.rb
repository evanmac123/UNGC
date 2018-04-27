require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase
  def setup
    @user = create_organization_and_user
    create_staff_user
    create_local_network_with_report_recipient
  end

  test "should get index" do
    sign_in @staff_user
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "should get new" do
    sign_in @staff_user
    get :new, {}
    assert_response :success
    assert_template partial: '_new_signatory_form'
  end

  test "should create organization" do
    sign_in @staff_user
    sector = create(:sector)
    listing_status = create(:listing_status)
    assert_difference('Organization.count') do
      post :create, {organization: {name: 'Unspace',
                                       organization_type_id: OrganizationType.first.id,
                                       sector_id: sector.id,
                                       listing_status_id: listing_status.id,
                                       employees: 500,
                                       country_id: @country.id}}
    end

    assert_response :redirect
  end

  test "should show organization" do
    sign_in @user
    get :show, {id: @organization.to_param}
    assert_response :success
  end

  test "should not show other organizations to user" do
    @organization = create(:organization, name: 'SME',
                           employees: 50,
                           organization_type: OrganizationType.first)
    sign_in @user
    get :show, {id: @organization.to_param}
    assert_redirected_to dashboard_path
    assert_equal "You do not have permission to access that resource.", flash[:error]
  end

  test "should get edit" do
    sign_in @staff_user
    get :edit, {id: @organization.to_param}
    assert_response :success
  end

  test "staff should update organization and redirect to organization show view" do
    sign_in @staff_user
    put :update, {id: @organization.to_param, organization: { }}
    assert_redirected_to admin_organization_path(assigns(:organization).id)
  end

  test "should destroy organization" do
    sign_in @user
    assert_difference('Organization.count', -1) do
      delete :destroy, {id: @organization.to_param}
    end

    assert_redirected_to admin_organizations_path
  end

  test "should list approved organizations" do
    sign_in @staff_user
    get :approved, {}
    assert_response :success
  end

  test "should list pending organizations" do
    sign_in @staff_user
    get :pending_review, {}
    assert_response :success
  end

  test "should list updated organizations" do
    sign_in @staff_user
    get :updated, {}
    assert_response :success
  end

  test "should list network review organizations" do
    sign_in @staff_user
    get :network_review, {}
    assert_response :success
  end

  test "should list rejected organizations" do
    sign_in @staff_user
    get :rejected, {}
    assert_response :success
  end

  test "should list organizations in review" do
    sign_in @staff_user
    get :in_review, {}
    assert_response :success
  end

  test "should redirect participants to main dashboard after updating" do
    sign_in @user
    put :update, {id: @organization.to_param, organization: { }}
    assert_redirected_to dashboard_path
  end


  context "given an organization in review" do
    setup do
      @organization.state = Organization::STATE_IN_REVIEW
    end

    should "should set replied_to to false after a user updates" do
      sign_in @user
      put :update, {id: @organization.to_param, organization: { }}
      @organization.reload
      assert_equal false, @organization.replied_to
      assert_redirected_to dashboard_path
    end

    should "should set replied_to to true after a staff user updates" do
      sign_in @staff_user
      put :update, {id: @organization.to_param, organization: { }}
      @organization.reload
      assert_equal true, @organization.replied_to
      assert_redirected_to admin_organization_path(@organization.id)
    end

    should "not reverse roles without one CEO and Contact Point" do
      sign_in @staff_user
      get :reverse_roles, {id: @organization.to_param}
      assert_equal 'Sorry, the roles could not be reversed. There can only be one Contact Point and one CEO to reverse roles.', flash[:error]
      assert_redirected_to admin_organization_path(@organization.id)
    end

    should "reverse roles" do
      create_organization_and_ceo
      sign_in @staff_user
      get :reverse_roles, {id: @organization.to_param}
      assert_equal 'The CEO and Contact Point roles were reversed.', flash[:notice]
      assert_redirected_to admin_organization_path(@organization.id)
    end

    should "be able to edit Letter of Commitment" do
      sign_in @user
      get :edit, {id: @organization.to_param}
      assert_select "input#organization_commitment_letter"
    end

    should "not see Country select" do
      sign_in @user
      get :edit, {id: @organization.to_param}
      assert_select "select#organization_country_id", 0
    end

    should "staff should see the fieldset for selecting why they are in review" do
      # sign_in @staff_user
      # get :edit, {id: @organization.to_param}
      # assert_select "fieldset#review_reason"
    end

  end

  context "given an approved organization" do
    setup do
      @organization.approve
    end

    context "as user" do
      setup do
        sign_in @user
      end

      should "user should not see upload field for commitment letter" do
        get :edit, {id: @organization.to_param}
        assert_select "input#organization_commitment_letter", 0
      end
    end

    context "as staff user" do
      setup do
        sign_in @staff_user
      end

      should "succeed and require delisted on date when being manually delisted" do
        put :update, {id: @organization.to_param, organization: { active: "0", delisted_on: Date.current }}
        assert_redirected_to admin_organization_path(@organization.id)
      end

      should "fail when being manually delisted and delisted_on date is not provided" do
        put :update, {id: @organization.to_param, organization: { cop_state: Organization::COP_STATE_DELISTED }}
        assert_template "edit"
      end
    end
  end

  context "given a rejected organization" do
     setup do
       @organization.reject
     end

     should "applicant should not be able to edit" do
       sign_in @user
       get :edit, {id: @organization.id}
       assert_equal "We're sorry, your organization's application was not approved. No edits or comments can be made.", flash[:error]
       assert_redirected_to admin_organization_path(@user.organization.id)
     end

     should "staff should still be able to edit" do
       sign_in @staff_user
       get :edit, {id: @organization.id}
       assert_response :success
     end
   end

  context "given a non business organization" do

    setup do
      @user = create_non_business_organization_and_user
    end

    should "update non business organization registration" do
      sign_in @user
      put :update, {id: @organization.to_param, organization: {  },
                                       non_business_organization_registration: {number: "test",
                                        date: "12/3/2013",
                                        place: "bla",
                                        authority: "bla",
                                        mission_statement: "A"}}
      assert_equal @organization.registration.number, "test"
    end

    should "update non business organization registration without requiring a number if legal status is provided" do
      sign_in @user
      put :update, {id: @organization.to_param, organization: {
                                        legal_status_file: fixture_file_upload('files/untitled.pdf', 'application/pdf')
                                       },
                                       non_business_organization_registration: {
                                        date: "12/3/2013",
                                        place: "bla",
                                        authority: "bla",
                                        mission_statement: "A"}}
      refute @organization.legal_status.blank?
      assert_redirected_to dashboard_path
    end

    should "reject non business organization registration" do
      sign_in @user
      put :update, {id: @organization.to_param, non_business_organization_registration: {}, organization: {  }}
      assert_template "admin/organizations/edit"
    end

    should "reject non business organization registration that has no number or legal status" do
      sign_in @user
      put :update, {id: @organization.to_param, organization: {
                                       },
                                       non_business_organization_registration: {
                                        date: "12/3/2013",
                                        place: "bla",
                                        authority: "bla",
                                        mission_statement: "A"}}
      assert_template "admin/organizations/edit"
    end

    should "reject non business organization registration that has an authority name too long" do
      sign_in @user
      put :update, {id: @organization.to_param, organization: {
                                       },
                                       non_business_organization_registration: {
                                        date: "12/3/2013",
                                        number: "test",
                                        place: "bla",
                                        authority: "bla"*100,
                                        mission_statement: "A"}}
      assert_template "admin/organizations/edit"
    end

  end

  context "showing exclusionary criteria" do

    should "show when the policy allows it" do
      sign_in create(:staff_contact)
      organization = create(:organization)

      # Given we should be showing exclusionary criteria
      OrganizationPresenter.any_instance
        .expects(:should_show_exclusionary_criteria?)
        .returns(true)

      # When we visit the page
      get :show, id: organization
      assert_response :success

      # We see them
      assert_select "*[role='exclusionary-criteria']"
    end

    should "not show the policy denies it" do
      sign_in create(:staff_contact)
      organization = create(:organization)

      # Given we should be showing exclusionary criteria
      OrganizationPresenter.any_instance
        .expects(:should_show_exclusionary_criteria?)
        .returns(false)

      # When we visit the page
      get :show, id: organization
      assert_response :success

      # We don't see them
      assert_select "*[role='exclusionary-criteria']", false
    end

  end

  context "Editing exclusionary criteria" do

    should "show the fields when allowed" do
      sign_in @user

      # Given we should be allowed to edit exclusionary criteria
      OrganizationPresenter.any_instance
        .expects(:can_edit_exclusionary_criteria?)
        .returns(true)

      get :edit, id: @user.organization

      assert_response :success
      assert_select "input[name='organization[is_landmine]']"
    end

    should "not show the fields when denied" do
      sign_in @user

      # Given we should NOT be allowed to edit exclusionary criteria
      OrganizationPresenter.any_instance
        .expects(:can_edit_exclusionary_criteria?)
        .returns(false)

      get :edit, id: @user.organization

      assert_response :success
      assert_select "input[name='organization[is_landmine]']", false
    end

  end

end
