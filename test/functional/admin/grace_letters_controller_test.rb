require 'test_helper'

class Admin::GraceLettersControllerTest < ActionController::TestCase
  context "given a Grace Letter" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options(:type => 'grace')
      sign_in @organization_user
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
    end

    should "view with the Grace Letter partial" do
      assert assigns(@grace_letter)
    end
  end

  #TODO test with user from_uncg?!!!

end
