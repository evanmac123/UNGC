require 'test_helper'

class Admin::GraceLettersControllerTest < ActionController::TestCase

  setup do
    create_approved_organization_and_user
    sign_in @organization_user
  end

  should "show" do
    get :show, organization_id: @organization.id, id: create_grace_letter.id

    assert assigns(:grace_letter)
  end

  should "new" do
    get :new, organization_id: @organization.id
    form = assigns(:form)

    assert_not_nil form
  end

  context "Editing" do
    setup do
      @editable = create_grace_letter
      @editable.update_attribute(:state, ApprovalWorkflow::STATE_PENDING_REVIEW)
      @not_editable = create_grace_letter
    end

    context "a grace letter that is still editable" do

      should "show the edit form" do
        get :edit, organization_id: @organization.id, id: @editable.id

        assert_not_nil assigns(:form)
        assert_template :edit
      end

      should "update the grace letter" do
        put :update,  id: @editable.id,
                      organization_id: @organization.id,
                      grace_letter: cop_file_attributes
        form = assigns(:form)

        assert form.valid?, "expected grace_letter to be valid."
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, form.id)
      end

    end

    context "a grace letter that is not editable" do
      should "redirect away from edit" do
        get :edit, id: @not_editable.id, organization_id: @organization.id

        refute @not_editable.editable?
        assert_redirected_to admin_organization_url(@organization.id, tab: :cops)
      end

      should "redirect away" do
        put :update,  id: @not_editable.id,
                      organization_id: @organization.id,
                      grace_letter: cop_file_attributes
        form = assigns(:form)

        assert form.valid?, "expected grace letter to be valid. : #{Array(form.errors).join("\n")}"
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, form.id)
      end
    end

  end

  context "create" do
    context "with valid attributes" do

      should "create a new grace letter" do
        post :create, organization_id: @organization.id, grace_letter: cop_file_attributes
        form = assigns(:form)

        assert form.valid?, "expected form to be valid."
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, form.id)
      end
    end

    context "with invalid attributes" do
      should "show the new form" do
        post :create, organization_id: @organization.id, grace_letter: {}

        assert_template :new
      end
    end

  end

  context "Destroy" do
    should "destroy the grace letter" do
      grace_letter = create_grace_letter

      assert_difference('CommunicationOnProgress.count', -1) do
        delete :destroy, organization_id: @organization.id,
                         id: grace_letter.to_param
      end
      assert_redirected_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

end
