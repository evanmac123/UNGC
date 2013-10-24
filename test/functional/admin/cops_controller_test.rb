require 'test_helper'

class Admin::CopsControllerTest < ActionController::TestCase
  context "given a pending organization and user" do
    setup do
      create_organization_and_user
      create_principle_areas
      sign_in @organization_user
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
      create_approved_organization_and_user
      create_principle_areas
      sign_in @organization_user
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
       sign_in @organization_user
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

      %w{basic intermediate advanced lead grace}.each do |cop_type|
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
      sign_in @organization_user
    end

    should "be redirected to non_business COP template" do
      get :introduction
      assert_redirected_to new_admin_organization_communication_on_progress_path(:organization_id => @organization.id, :type_of_cop => 'non_business')
    end

  end

  context "given a company that is a signatory of LEAD" do
    setup do
      create_organization_and_user
      @organization.approve!
      create_initiatives
      initiative = Initiative.for_filter(:lead).first
      create_signing(:organization_id => @organization.id, :initiative_id => initiative.id)
    end

    should "get the LEAD COP form" do
      sign_in @organization_user
      get :introduction
      assert_template "lead_introduction"
    end

  end

  context "given a new basic cop" do
    setup do
      create_organization_and_user
      @organization.approve!
      create_principle_areas
      create_language
      sign_in @organization_user
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
                      :ends_on                      => Date.today,
                      :differentiation              => 'learner'
                    }
    end

    should "confirm the format" do
       assert_redirected_to admin_organization_communication_on_progress_path(:organization_id => @organization.id,
                                                                              :id => assigns(:communication_on_progress).id)
       assert_equal 'basic', assigns(:communication_on_progress).format
    end

    should "make sure the contact information has been saved" do
      assert_equal @organization_user.contact_info, assigns(:communication_on_progress).contact_name
    end

  end

  context "given an existing cop" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options
      sign_in @organization_user
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

  context "given a COP submitted between 2010-01-01 and 2011-01-29" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options :created_at => Date.parse('31-12-2010')
      sign_in @organization_user
    end
    should "show the new style template" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
     assert_template :partial => '_show_new_style'
    end
  end

  context "given a Grace Letter" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options(:type => 'grace')
      sign_in @organization_user
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
    end

    should "view with the Grace Letter partial" do
      assert_equal '/shared/cops/show_grace_style', assigns(:cop_partial)
      assert_template :partial => '_show_grace_style'
    end

  end

  context "given a COP on the Learner Platform" do
    setup do
      create_approved_organization_and_user
      # if any item is missing, then the COP puts the participant on the Learner Platform
      create_cop_with_options(:include_measurement => false)
      sign_in @organization_user
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
    end

    should "display learner partial" do
      assert_equal assigns(:cop_partial), '/shared/cops/show_learner_style'
      assert_equal assigns(:results_partial), '/shared/cops/show_differentiation_style'
      assert_template :partial => '_show_learner_style'
    end
  end

  context "given two Learner COPs in a row" do
    setup do
      create_organization_and_user
      @organization.approve!
      @first_cop  = create_cop(@organization.id, { :references_environment  => false })
      @second_cop = create_cop(@organization.id, { :references_human_rights => false })
    end

    should "call correct email templates" do
      assert @organization.double_learner?
      assert_equal @second_cop.confirmation_email,'double_learner'
    end
  end

  context "given a GC Active COP" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options
      sign_in @organization_user
    end

    should "display active partial" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_equal assigns(:cop_partial), '/shared/cops/show_active_style'
      assert_equal assigns(:results_partial), '/shared/cops/show_differentiation_style'
      assert_template :partial => '_show_active_style'
    end
  end

  context "given a GC Advanced COP" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options({:meets_advanced_criteria => true, :type => 'advanced'})
      sign_in @organization_user
    end

    should "display advanced partial" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_equal assigns(:cop_partial), '/shared/cops/show_advanced_style'
      assert_equal assigns(:results_partial), '/shared/cops/show_differentiation_style'
      assert_template :partial => '_show_advanced_style'
    end
  end

  context "given a COP submitted that is not a Grace Letter" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options
      sign_in @organization_user
    end

    should "send a confirmation email" do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        post :create, :organization_id => @organization.id,
                      :communication_on_progress => {
                        :title                        => 'Our COP',
                        :references_human_rights      => true,
                        :references_labour            => true,
                        :references_environment       => true,
                        :references_anti_corruption   => true,
                        :include_measurement          => true,
                        :starts_on                    => Date.today,
                        :ends_on                      => Date.today,
                        :differentiation              => 'active'
                      }
      end
    end

  end

  context "given a company that has submitted three Learner COPs" do
    setup do
      create_approved_organization_and_user
      @first_cop  = create_cop_with_options({:title => 'First COP', :include_continued_support_statement => false})
      @second_cop = create_cop_with_options({:title => 'Second COP', :references_environment => false})
      @third_cop  = create_cop_with_options({:title => 'Third COP', :include_measurement => false})
    end

    should "should identify if time passed between COPs is one or more years" do
      @first_cop.update_attribute  :created_at, Date.new(2011,03,01)
      @second_cop.update_attribute :created_at, Date.new(2011,04,01)
      @third_cop.update_attribute  :created_at, Date.new(2012,03,02)
      assert @organization.triple_learner_for_one_year?
    end

    should "not identify them as triple_learner_for_one_year if less than one year" do
      @first_cop.update_attribute  :created_at, Date.new(2011,03,01)
      @second_cop.update_attribute :created_at, Date.new(2011,04,01)
      @third_cop.update_attribute  :created_at, Date.new(2011,05,01)
      assert !@organization.triple_learner_for_one_year?
    end

    should "not identify them as triple_learner_for_one_year if the exact deadline has not been exceeded" do
      @first_cop.update_attribute  :created_at, Date.new(2011,03,02)
      @second_cop.update_attribute :created_at, Date.new(2011,04,02)
      @third_cop.update_attribute  :created_at, Date.new(2012,03,01)
      assert !@organization.triple_learner_for_one_year?
    end
  end

  context "given two non-consecutive Learner COPs" do
    setup do
      create_approved_organization_and_user
      @first_cop  = create_cop_with_options({:include_continued_support_statement => false})
      @second_cop = create_cop_with_options
      @third_cop = create_cop_with_options({:include_measurement => false})
      @first_cop.update_attribute  :created_at, Date.new(2011,03,01)
      @second_cop.update_attribute :created_at, Date.new(2012,03,01)
      @third_cop.update_attribute  :created_at, Date.new(2013,03,01)
      sign_in @organization_user
    end
    should "not identify them as triple_learner_for_one_year" do
      assert !@organization.triple_learner_for_one_year?
    end
  end

  private

  def create_approved_organization_and_user
    create_organization_and_user
    @organization.approve!
  end

    def create_cop_with_options(cop_options = {})
      # let's assume an Active COP where all criteria have been met
      defaults = {
        :title                               => "COP Title",
        :references_human_rights             => true,
        :references_labour                   => true,
        :references_environment              => true,
        :references_anti_corruption          => true,
        :include_measurement                 => true,
        :include_continued_support_statement => true
      }

      create_principle_areas
      @cop = create_cop(@organization.id, defaults.merge(cop_options))
    end


end
