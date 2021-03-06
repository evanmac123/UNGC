require 'test_helper'
require 'sidekiq/testing'

class Admin::GraceLettersControllerTest < ActionController::TestCase

  setup do
    create_approved_organization_and_user
    create(:language, name: "English")
    sign_in @organization_user
    Sidekiq::Testing.inline!
  end

  teardown do
    Sidekiq::Testing.fake!
  end

  should "show" do
    grace_letter = create(:grace_letter, organization: @organization)
    get :show, organization_id: @organization.id, id: grace_letter.id

    assert assigns(:grace_letter)
  end

  should "new" do
    get :new, organization_id: @organization.id
    form = assigns(:form)

    assert_not_nil form
  end

  context "Editing" do
    setup do
      @grace_letter = create(:grace_letter, organization: @organization)
    end

    context "as a staff user" do
      setup do
        create_staff_user
        sign_in @staff_user
      end

      context "a grace letter that is still grace_letter" do
        should "show the edit form" do
          get :edit, organization_id: @organization.id, id: @grace_letter.id

          assert_not_nil assigns(:form)
          assert_template :edit
        end

        should "update the grace letter" do
          put :update,  id: @grace_letter.id,
                        organization_id: @organization.id,
                        grace_letter: grace_letter_attributes
          form = assigns(:form)

          assert form.valid?, form.errors.full_messages
          assert_redirected_to admin_organization_grace_letter_url(@organization.id, form.grace_letter)
        end
      end

    end

    context "as an organization user" do
      context "a grace letter that is still grace_letter" do
        should "show the edit form" do
          get :edit, organization_id: @organization.id, id: @grace_letter.id

          assert_redirected_to dashboard_path
        end

        should "update the grace letter" do
          put :update,  id: @grace_letter.id,
                        organization_id: @organization.id,
                        grace_letter: cop_file_attributes
          assert_redirected_to dashboard_path
        end
      end

    end

  end

  context "create" do
    context "with valid attributes" do
      should "create a new grace letter" do
        post :create, organization_id: @organization.id, grace_letter: grace_letter_attributes
        form = assigns(:form)

        assert form.valid?, "expected form to be valid."
        assert_redirected_to admin_organization_grace_letter_url(@organization.id, form.grace_letter)
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
      grace_letter = create(:grace_letter, organization: @organization)

      assert_difference('CommunicationOnProgress.count', -1) do
        delete :destroy, organization_id: @organization.id,
                         id: grace_letter.to_param
      end
      assert_redirected_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  private

  def grace_letter_attributes
    cop_file_attributes.merge(language_id: create(:language).id)
  end

end
