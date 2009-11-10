require 'test_helper'

class Admin::CopsControllerTest < ActionController::TestCase
  context "given a organization user" do
    setup do
      create_organization_and_user
      create_principle_areas
      login_as @organization_user
    end

    context "creating a new cop" do
      should "get the new cop form" do
        get :new, :organization_id => @organization.id
        assert_response :success
      end
    end
  end
  
  context "given an existing cop" do
    setup do
      create_organization_and_user
      create_principle_areas
      login_as @organization_user
    end
    
    should "be able to see the cop details" do
      # code here
    end
    
    should "be able to edit the cop" do
      # code here
    end
  end
end
