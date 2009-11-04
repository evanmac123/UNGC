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
end
