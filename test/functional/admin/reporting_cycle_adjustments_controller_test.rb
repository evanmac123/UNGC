require 'test_helper'

class Admin::ReportingCycleAdjustmentsControllerTest < ActionController::TestCase
  setup do
    create_approved_organization_and_user
    sign_in @organization_user
  end

  should "show" do
    get :show, organization_id: @organization.id, id: create_reporting_cycle_adjustment.id

    assert assigns(:cycle_adjustment)
  end

  should "new" do
    get :new, organization_id: @organization.id

    assert_not_nil assigns(:cycle_adjustment)
  end

  context "Create" do
    context "with valid attributes" do
      setup do
        @attrs = valid_reporting_cycle_adjustment_attributes
          .merge({
            ends_on: Date.today + 11.months,
            cop_files_attributes:[valid_cop_file_attributes]
          })
      end

      should "create a new reporting cycle adjustment" do
        post :create, organization_id: @organization.id, communication_on_progress: @attrs
        cycle_adjustment = assigns(:cycle_adjustment)

        assert cycle_adjustment.valid?, "expected reporting cycle adjustment to be valid."
        assert_redirected_to admin_organization_reporting_cycle_adjustment_url(@organization.id, cycle_adjustment.id)
      end
    end

    context "with invalid attributes" do
      setup do
        @attrs = valid_reporting_cycle_adjustment_attributes
      end

      should "show the new form" do
        post :create, organization_id: @organization.id, communication_on_progress: @attrs

        assert_template :new
      end
    end

  end

  context "Editing" do
    # TODO
  end
end
