require 'test_helper'

class Admin::CopsControllerTest < ActionController::TestCase
  context "given a pending organization and user" do
    setup do
      create_organization_and_user
      create_principle_areas
      login_as @organization_user
    end

    context "creating a new cop" do
      should "get the new cop form" do
        get :new, :organization_id => @organization.id
        assert_redirected_to admin_organization_path(@organization.id)
      end
    end
  end
  
  context "given an approved organization user" do
    setup do
      create_organization_and_user
      @organization.approve!
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
      @organization.approve!
      create_principle_areas
      @cop = create_communication_on_progress(:organization_id => @organization.id)
      login_as @organization_user
    end
    
    should "be able to see the cop details" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_response :success
    end
    
    should "be able to edit the cop" do
      get :edit, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_response :success
    end
    
    should "be able to update the cop" do
      put :update, :organization_id => @organization.id,
                   :id              => @cop.id,
                   :communication_on_progress => {}
      assert_response :redirect
    end
  end
end
