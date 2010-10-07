require 'test_helper'

class Admin::CopsControllerTest < ActionController::TestCase
  context "given a pending organization and user" do
    setup do
      create_organization_and_user
      create_principle_areas
      login_as @organization_user
    end

    context "creating a new cop" do
      should "not get the new cop form" do
        get :new, :organization_id => @organization.id
        assert_response :redirect
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

    context "given a new cop" do    
      %w{basic intermediate advanced}.each do |cop_type|
        should "get the #{cop_type} cop form" do
          get :new, :organization_id => @organization.id, :type_of_cop => cop_type
          assert_response :success
          assert_template :new
          assert_template :partial => "_#{cop_type}_form"
        end        
      end
      should "redirect to introduction page if the type_of_cop parameter is not valid" do
        get :new, :organization_id => @organization.id, :type_of_cop => "bad type"
        assert_redirected_to cop_introduction_path
      end
    end
    
  end
  
  context "given a new basic cop" do
    setup do
      @request.session[:cop_template] = 'basic'
      create_organization_and_user
      @organization.approve!
      create_principle_areas
      create_language
      get :new, :organization_id => @organization.id
      post :create, { :organization_id                     => @organization.id,
                      :include_continued_support_statement => true,
                      :references_human_rights             => true,
                      :references_labour                   => true,
                      :references_environment              => true,
                      :references_anti_corruption          => true,
                      :include_measurement                 => true,
                      :starts_on                           => Date.today,
                      :ends_on                             => Date.today,
                      :cop_files_attributes => {
                       "new_cop"=> {:attachment_type => "cop", :language_id => Language.first.id}
                      }
                    }
                      
                      
    end
    should "confirm the format" do
      assert_equal 'basic', session[:cop_template]
      # FIXME: test if format has been set
      # @cop = CommunicationOnProgress.find(:last)
      # assert_equal 'basic', @cop.format
    end
  end
  
  context "given an existing cop" do
    setup do
      create_organization_and_user
      @organization.approve!
      create_principle_areas
      @cop = create_cop(@organization.id)
      login_as @organization_user
    end
    
    should "be able to see the cop details" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_response :success
    end
    
    should "not be able to edit the cop" do
      get :edit, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_redirected_to dashboard_path(tab: 'cops')
    end
    
    should "be able to update the cop" do
      put :update, :organization_id => @organization.id,
                   :id              => @cop.id,
                   :communication_on_progress => {}
      assert_response :redirect
    end
  end
end
