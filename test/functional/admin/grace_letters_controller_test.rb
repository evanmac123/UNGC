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
    grace_letter = assigns(:grace_letter)

    assert_not_nil grace_letter
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

        assert_not_nil assigns(:grace_letter)
        assert_template :edit
      end

      should "update the grace letter" do
        attrs = @editable.attributes.merge(
          title: 'new_title',
          cop_files_attributes: [valid_cop_file_attributes]
        )
        put :update,  id: @editable.id,
                      organization_id: @organization.id,
                      communication_on_progress: attrs
        grace_letter = assigns(:grace_letter)

        assert grace_letter.valid?, "expected grace_letter to be valid."
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, grace_letter.id)
      end

    end

    context "a grace letter that is not editable" do
      should "redirect away from edit" do
        get :edit, id: @not_editable.id,   organization_id: @organization.id

        refute @not_editable.editable?
        assert_redirected_to admin_organization_url(@organization.id, tab: :cops)
      end

      should "redirect away" do
        attrs = @not_editable.attributes.merge(cop_files_attributes: [valid_cop_file_attributes])
        put :update,  id: @not_editable.id,
                      organization_id: @organization.id,
                      communication_on_progress: attrs
        grace_letter = assigns(:grace_letter)

        assert grace_letter.valid?, "expected grace letter to be valid. : #{Array(grace_letter.errors).join("\n")}"
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, grace_letter.id)
      end
    end

  end

  context "create" do
    context "with valid attributes" do
      setup do
        @attrs = valid_grace_letter_attributes
          .merge(cop_files_attributes:[valid_cop_file_attributes])
      end

      should "create a new grace letter" do
        post :create, organization_id: @organization.id, communication_on_progress: @attrs
        grace_letter = assigns(:grace_letter)

        assert grace_letter.valid?, "expected grace_letter to be valid."
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, grace_letter.id)
      end
    end

    context "with invalid attributes" do
      setup do
        @attrs = valid_grace_letter_attributes
      end

      should "show the new form" do
        post :create, organization_id: @organization.id, communication_on_progress: @attrs

        assert_template :new
      end
    end

  end

  #TODO test with user from_uncg?!!!

end
