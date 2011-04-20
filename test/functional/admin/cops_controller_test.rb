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
   
   context "with an Active status and within 90 day grace letter period" do
     setup do
       @organization.update_attribute :cop_due_on, Date.today - 75.days
       @organization.reload
     end
     should "see Grace Letter tab" do
       get :introduction
       assert_response :success
       assert_select 'ul.tab_nav' do
         assert_select 'li:last-child', 'Grace Letter'
       end
     end
   end

   context "who has already submitted a grace letter" do
     setup do
       @organization.update_attribute :cop_due_on, Date.today - 75.days
       @cop = create_communication_on_progress(organization: @organization, format: 'grace_letter')
       @cop.type = 'grace'
       @cop.save
       @organization.reload
   end
     should "should not see Grace Letter tab" do
       get :introduction
       assert_response :success
       assert_select 'ul.tab_nav' do
         assert_select 'li:last-child', 'Advanced Level'
       end
     end
   end

   context "with a Delisted status" do
     setup do
       create_organization_and_user
       @organization.approve!
       # state machine requires organization to be non-communicating first
       @organization.communication_late
       @organization.delist
       login_as @organization_user
     end
     should "not see Grace Letter tab" do
       assert @organization.delisted?
       get :introduction
       assert_response :success
       assert_select 'ul.tab_nav' do
         assert_select 'li:last-child', 'Advanced Level'
       end
     end
   end

    context "given a new cop" do
        
      %w{basic intermediate advanced grace}.each do |cop_type|
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
  
  context "given a non-business submitting a COP" do

    setup do
      create_non_business_organization_and_user('approved')
      login_as @organization_user
    end

    should "be redirected to intermediate COP template" do
      get :introduction
      assert_redirected_to new_admin_organization_communication_on_progress_path(:organization_id => @organization.id, :type_of_cop => 'intermediate')
    end

  end
  
  context "given a new basic cop" do
    setup do
      create_organization_and_user
      @organization.approve!
      create_principle_areas
      create_language
      login_as @organization_user
      get :new, :organization_id => @organization.id, :type_of_cop => 'basic'
      post :create, :organization_id => @organization.id,
                    :communication_on_progress => {
                      :title                        => 'Our COP',
                      :references_human_rights      => true,
                      :references_labour            => true,
                      :references_environment       => true,
                      :references_anti_corruption   => true,
                      :include_measurement          => true,
                      :starts_on                    => Date.today,
                      :ends_on                      => Date.today
                    }
      
    end

    should "confirm the format" do
       assert_redirected_to admin_organization_communication_on_progress_path(:organization_id => @organization.id,
                                                                              :id => assigns(:communication_on_progress).id)
       assert_equal 'basic', assigns(:communication_on_progress).format
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
      assert_redirected_to admin_organization_path(@organization.id, :tab => 'cops')
    end
    
    should "be able to update the cop" do
      put :update, :organization_id => @organization.id,
                   :id              => @cop.id,
                   :communication_on_progress => {}
      assert_response :redirect
    end
  end
end
