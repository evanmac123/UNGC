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
  end

  #TODO test with user from_uncg?!!!

end
