require 'test_helper'

class Admin::GraceLettersControllerTest < ActionController::TestCase
  context "given a Grace Letter" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options(:type => 'grace')
      sign_in @organization_user
    end

    should "show" do
      get :show, organization_id: @organization.id, id: @cop.id
      assert assigns(:grace_letter)
    end

    should "new" do
      get :new, organization_id: @organization.id
    end

    # context "the grace letter is still editable" do
    #   should "edit" do
    #     assert false, "pending"
    #   end
    # end

    # context "the grace letter is not editable" do
    #   should "not edit" do
    #     assert false, "pending"
    #   end
    # end

    context "with valid attributes" do
      setup do
        @attrs = valid_grace_letter_attributes.merge("id" => 123)
      end

      should "create a new grace letter" do
        cop = create_grace_letter
        # puts cop.attributes.to_s

        attrs = valid_grace_letter_attributes.merge(cop_file_attributes: valid_cop_file_attributes)
        post :create, organization_id: @organization.id, grace_letter: attrs
        # g = CommunicationOnProgress.create! valid_grace_letter_attributes
        # p = GraceLetterForm.new(g)
        # puts valid_grace_letter_attributes
        # assert p.valid?, Array(p.errors).join("\n")

        assert_redirected_to admin_organization_grace_letter_url(@organization.id, @attrs['id'])
      end
    end

    # context "with invalid attributes" do
    #   setup do
    #   end

    #   should "show the new form" do
    #     submitted = assigns(:submitted)
    #     assert submitted
    #     assert false, "pending"
    #   end
    # end

  end

  #TODO test with user from_uncg?!!!

end
