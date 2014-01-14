require 'test_helper'

class Admin::GraceLettersControllerTest < ActionController::TestCase

  setup do
    create_approved_organization_and_user
    sign_in @organization_user
  end

  should "new" do
    get :new, organization_id: @organization.id
    grace_letter = assigns(:grace_letter)

    assert_not_nil grace_letter
  end

  context "given a Grace Letter" do
    setup do
      @editable = create_grace_letter
      @editable.update_attribute(:state, ApprovalWorkflow::STATE_PENDING_REVIEW)
      @not_editable = create_grace_letter
    end

    should "show" do
      get :show, organization_id: @organization.id, id: @editable.id

      assert assigns(:grace_letter)
    end

    context "the grace letter is still editable" do

      should "edit" do
        assert @editable.editable?, "it should be editable."
        get :edit, organization_id: @organization.id, id: @editable.id

        assert_not_nil assigns(:grace_letter)
        assert_template :edit
      end

      should "update" do
        attrs = @editable.attributes.merge(
          title: 'new_title',
          cop_files_attributes: [valid_cop_file_attributes]
        )
        put :update, organization_id: @organization.id, communication_on_progress: attrs
        grace_letter = assigns(:grace_letter)

        assert grace_letter.valid?, "expected grace_letter to be valid."
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, grace_letter.id)
      end

    end

    # context "the grace letter is not editable" do
    #   should "not edit" do
    #     assert false, "pending"
    #   end
    # end

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
