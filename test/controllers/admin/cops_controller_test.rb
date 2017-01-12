require 'test_helper'
require 'sidekiq/testing'

class Admin::CopsControllerTest < ActionController::TestCase

  setup do
    Sidekiq::Testing.inline!
  end

  teardown do
    Sidekiq::Testing.fake!
  end

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
        links = assert_select 'ul.tab_nav li a'
        assert_includes links.map(&:text), 'Grace Letter'
      end
    end

    context "who has already submitted a grace letter" do
      setup do
        @organization.update_attribute :cop_due_on, Date.today - 75.days
        @cop = create(:communication_on_progress, organization: @organization, format: 'grace_letter')
        @cop.cop_type = 'grace'
        @cop.save
        @organization.reload
      end
      should "should not see Grace Letter tab" do
        get :introduction

        assert_response :success
        links = assert_select 'ul.tab_nav li a'
        assert_not_includes links.map(&:text), 'Grace Letter'
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
        links = assert_select 'ul.tab_nav li a'
        assert_not_includes links.map(&:text), 'Grace Letter'
      end
    end

    context "SMEs" do
      setup do
        create_organization_and_user
        @organization.approve!
        @organization.update(employees: 11)
        sign_in @organization_user
      end
      should "see the Express COP tab" do
        assert 'SME', @organization.organization_type.try(:name)
        get :introduction
        tabs = assert_select 'ul.tab_nav li a'
        assert_includes tabs.map(&:text), 'Express'
      end
    end

    context "Non-SME" do
      setup do
        create_organization_and_user
        @organization.approve!
        @organization.update(employees: 10000)
        sign_in @organization_user
      end
      should "hide the Express COP tab" do
        assert_not_equal 'SME', @organization.organization_type.try(:name)
        get :introduction
        tabs = assert_select 'ul.tab_nav li a'
        assert_not_includes tabs.map(&:text), 'Express Template'
      end
    end

    context "given a new cop" do

      %w{basic intermediate advanced lead}.each do |cop_type|
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

    context "validation messages" do

      should 'show validation errors for missing cop files' do
        language = create(:language)
        cop_params = {
          "cop_files_attributes" => { "0" => { "attachment_type" => "cop", "language_id" => language.id } },
          "cop_type" => "intermediate"
        }

        post :create, organization_id: @organization.id, communication_on_progress: cop_params
        cop = assigns(:communication_on_progress)

        assert_equal false, cop.persisted?
        assert_equal "Attachment can't be blank", cop.errors.full_messages.to_sentence
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
      assert_template :non_business_introduction
    end
  end

  context "given a company that is a signatory of LEAD" do
    setup do
      create_organization_and_user
      @organization.approve!
      initiative_id = Initiative.id_by_filter(:lead)
      create(:signing, :organization_id => @organization.id, :initiative_id => initiative_id)
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
      create(:language)
      sign_in @organization_user
      post :create, :organization_id => @organization.id,
                    :communication_on_progress => {
                      :cop_type => :basic,
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
      assert_equal @organization_user.contact_info, assigns(:communication_on_progress).contact_info
    end

  end

  context "given an existing cop and an organization user" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options({
        cop_type: 'basic'
      })
      sign_in @organization_user
    end

    should "be able to see the cop details" do
      get :show, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_response :success
    end
  end

  context "given an existing cop and a staff user" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options({
        cop_type: 'basic'
      })
      create_staff_user
      sign_in @staff_user
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
                   :communication_on_progress => {cop_type: :basic}
      assert_redirected_to admin_organization_communication_on_progress_url(@organization.id, @cop.id, tab: :results)
    end

    should "not be able to edit a cop that uses the legacy format" do
      create_cop_with_options :created_at => Date.parse('31-12-2008')
      get :edit, :organization_id => @organization.id,
                 :id              => @cop.id
      assert_redirected_to admin_organization_url(@organization, tab: :cops), "cops with legacy format are not editable"
    end

    should "not be able to update a cop that uses the legacy format" do
      create_cop_with_options :created_at => Date.parse('31-12-2008')
      put :update, :organization_id => @organization.id,
                   :id              => @cop.id,
                   :communication_on_progress => {}
      assert_redirected_to admin_organization_url(@organization, tab: :cops), "cops with legacy format are not editable"
    end

  end

  context "show action" do

    context "given a COP submitted before 2010-01-01" do
      setup do
        create_approved_organization_and_user
        create_cop_with_options :created_at => Date.parse('31-12-2008')
        sign_in @organization_user
      end
      should "show the legacy style template" do
        get :show, :organization_id => @organization.id,
                   :id              => @cop.id
       assert_template :partial => '_show_legacy_style'
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
        assert_template :partial => '_show_learner_style'
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
        assert_template :partial => '_show_active_style'
      end
    end

    context "given a GC Advanced COP" do
      setup do
        create_approved_organization_and_user
        create_cop_with_options({:meets_advanced_criteria => true, :cop_type => 'advanced'})
        sign_in @organization_user
      end

      should "display advanced partial" do
        get :show, :organization_id => @organization.id,
                   :id              => @cop.id
        assert_template :partial => '_show_advanced_style'
      end
    end

    context "given a blueprint COP" do
      setup do
        create_approved_organization_and_user
        create_cop_with_options({
          meets_advanced_criteria: true,
          cop_type: 'advanced'
        })
        @cop.update_attributes differentiation: 'blueprint'
        sign_in @organization_user
      end

      should "display blueprint partial" do
        get :show, :organization_id => @organization.id,
                   :id              => @cop.id
        assert_template :partial => '_show_blueprint_style'
      end
    end

    context "given a basic COP" do
      setup do
        create_approved_organization_and_user
        create_cop_with_options({
          cop_type: 'basic',
          created_at: Date.new(2011, 01, 10)
        })
        sign_in @organization_user
      end

      should "display basic partial" do
        get :show, :organization_id => @organization.id,
                   :id              => @cop.id
        assert_template :partial => '_show_basic_style'
      end
    end

    context "given a differentiation COP" do
      setup do
        create_approved_organization_and_user
        create_cop_with_options({
          cop_type: 'advanced',
          created_at: CommunicationOnProgress::START_DATE_OF_DIFFERENTIATION + 1.day,
        })
        sign_in @organization_user
      end

      should "display differentiation style partial" do
        get :show, :organization_id => @organization.id,
                   :id              => @cop.id
        assert_template :partial => '_show_differentiation_style'
      end
    end

    context "given a non_business style COP" do
      setup do
        create_non_business_organization_and_user('approved')
        create_cop_with_options({
          cop_type: 'non_business',
          created_at: CommunicationOnProgress::START_DATE_OF_NON_BUSINESS_COE,
        })
        sign_in @organization_user
      end

      should "display advanced partial" do
        get :show, :organization_id => @organization.id,
                   :id              => @cop.id
        assert_template :partial => '_show_non_business_style'
      end
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

  context "given a COP submitted that is not a Grace Letter" do
    setup do
      create_approved_organization_and_user
      create_cop_with_options
      sign_in @organization_user
    end

    # should "send a confirmation email" do
    #   assert_difference 'Sidekiq::Extensions::DelayedMailer.jobs.size' do
    #     post :create, :organization_id => @organization.id,
    #                   :communication_on_progress => {
    #                     :cop_type => 'basic',
    #                     :title                        => 'Our COP',
    #                     :references_human_rights      => true,
    #                     :references_labour            => true,
    #                     :references_environment       => true,
    #                     :references_anti_corruption   => true,
    #                     :include_measurement          => true,
    #                     :starts_on                    => Date.today,
    #                     :ends_on                      => Date.today,
    #                     :differentiation              => 'active'
    #                   }
    #   end
    # end

  end

  context "given an existing COP and a staff user" do
    setup do
      @due_date = Date.new(2012, 1, 1)
      @on_time = @due_date - 1.month
      @late = @due_date  + 1.month

      create_approved_organization_and_user
      create_cop_with_options({
        cop_type: 'basic',
        published_on: @due_date - 1.year,
        organization: @organization
      })
      @organization.update_attribute(:cop_due_on, @due_date)
      @organization.communication_late!
      @organization.save!

      create_staff_user
      sign_in @staff_user
    end

    should "be able to edit the published_on date" do
      get :backdate, :organization_id => @organization.id,
                     :id              => @cop.id
      assert_template :backdate
    end

    should "be able to set a new published_on date" do
      post :do_backdate, :organization_id => @organization.id,
                         :id              => @cop.id,
                         :published_on    => @on_time
      assert_redirected_to admin_organization_communication_on_progress_path(:organization_id => @organization.id, :id => @cop.id, :tab => :results)
    end

    should "be able to parse and set correctly a new published_on date" do
      post :do_backdate, :organization_id => @organization.id,
                         :id              => @cop.id,
                         :published_on    => @on_time
      assert_equal @cop.reload.published_on, @on_time
    end
  end

end
