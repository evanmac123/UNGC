require 'test_helper'

class Admin::ReportingCycleAdjustmentsControllerTest < ActionController::TestCase

  def to_date_params(date)
    {
      "ends_on(1i)" => date.year,
      "ends_on(2i)" => date.month,
      "ends_on(3i)" => date.day,
    }
  end

  def reporting_cycle_adjustment_attributes(organization = @organization)
    {
      language_id: Language.first,
      attachment: fixture_file_upload('files/untitled.pdf', 'application/pdf')
    }.merge(to_date_params(organization.cop_due_on + 10.months))
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

        refute form.has_errors?, form.errors.full_messages.to_sentence
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
      @reporting_cycle_adjustment = create_reporting_cycle_adjustment(
        ends_on: @organization.cop_due_on + 1.month
      )
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

          refute form.has_errors?, form.errors.full_messages.to_sentence
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

  context "Destroy" do
    should "destroy the reporting cycle adjustment" do
      reporting_cycle_adjustment = create_reporting_cycle_adjustment

      assert_difference('CommunicationOnProgress.count', -1) do
        delete :destroy, organization_id: @organization.id,
                         id: reporting_cycle_adjustment.to_param
      end
      assert_redirected_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

end
