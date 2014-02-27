require 'test_helper'

class Admin::ReportingCycleAdjustmentsControllerTest < ActionController::TestCase

  def to_date_params(date)
    {
      "ends_on(1i)" => date.year,
      "ends_on(2i)" => date.month,
      "ends_on(3i)" => date.day,
    }
  end

  def reporting_cycle_adjustment_attributes
    {
      language_id: Language.first,
      attachment: fixture_file_upload('files/untitled.pdf', 'application/pdf')
    }.merge(to_date_params(Date.today + 10.months))
  end

  setup do
    create_approved_organization_and_user
    create_language(name: "English")
    sign_in @organization_user
  end

  should "show" do
    get :show, organization_id: @organization.id, id: create_reporting_cycle_adjustment.id

    assert assigns(:cycle_adjustment)
  end

  should "new" do
    get :new, organization_id: @organization.id

    assert_not_nil assigns(:form)
  end

  context "Create" do
    context "with valid attributes" do
      setup do
        @attrs = reporting_cycle_adjustment_attributes
      end

      should "create a new reporting cycle adjustment" do
        post :create, organization_id: @organization.id, reporting_cycle_adjustment: @attrs
        form = assigns(:form)

        assert form.valid?, "expected reporting cycle adjustment to be valid."
        assert_redirected_to admin_organization_reporting_cycle_adjustment_url(@organization.id, form.reporting_cycle_adjustment)
      end
    end

    context "with invalid attributes" do
      setup do
        @attrs = valid_reporting_cycle_adjustment_attributes
      end

      should "show the new form" do
        post :create, organization_id: @organization.id, reporting_cycle_adjustment: @attrs

        assert_template :new
      end
    end

  end

  context "Editing" do
    setup do
      @reporting_cycle_adjustment = create_reporting_cycle_adjustment(ends_on: Date.today+1.month)

    end

    context "as a staff user" do
      setup do
        create_staff_user
        sign_in @staff_user
      end

      context "update reporting_cycle_adjustment" do

        should "show the edit form" do
          get :edit, organization_id: @organization.id, id: @reporting_cycle_adjustment.id

          assert_not_nil assigns(:form)
          assert_template :edit
        end

        should "update the reporting_cycle_adjustment" do
          put :update,  id: @reporting_cycle_adjustment.id,
                        organization_id: @organization.id,
                        reporting_cycle_adjustment: reporting_cycle_adjustment_attributes
          form = assigns(:form)

          assert form.valid?, "expected reporting_cycle_adjustment to be valid."
          assert_redirected_to admin_organization_reporting_cycle_adjustment_url(@organization.id, form.reporting_cycle_adjustment)
        end
      end
    end

    context "as an organization user" do
      should "show the edit form" do
        get :edit, organization_id: @organization.id, id: @reporting_cycle_adjustment.id
        assert_redirected_to dashboard_path
      end

      should "update the reporting_cycle_adjustment" do
        put :update,  id: @reporting_cycle_adjustment.id,
                      organization_id: @organization.id,
                      reporting_cycle_adjustment: reporting_cycle_adjustment_attributes
        assert_redirected_to dashboard_path
      end
    end
  end
end
