require 'test_helper'

class CommunicationOnProgressTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id
  should_belong_to :organization
  should_have_and_belong_to_many :languages
  should_have_and_belong_to_many :countries
  should_have_and_belong_to_many :principles
  should_have_many :cop_answers
  should_have_many :cop_files
  
  def pending_review(organization, options={})
    defaults = {
      :organization_id => organization.id,
      :state           => ApprovalWorkflow::STATE_PENDING_REVIEW,
      :ends_on         => Date.new(2009, 12, 31)
    }
    create_communication_on_progress(defaults.merge(options))
  end
  
  context "given a new COP" do
    setup do
      create_organization_and_user
      create_language
    end
    
    should "be invalid if there is no file" do
      assert_raise ActiveRecord::RecordInvalid do
        cop = create_communication_on_progress(:organization_id    => @organization.id,
                                               :format             => 'standalone',
                                               # :web_based          => false,
                                               :parent_company_cop => false,
                                               :include_continued_support_statement => true,
                                               :support_statement_signee            => 'ceo',
                                               :references_human_rights             => true,
                                               :references_labour                   => true,
                                               :references_environment              => true,
                                               :references_anti_corruption          => true,
                                               :include_measurement                 => true,
                                               :ends_on                             => Date.today,
                                               :cop_files_attributes => {
                                                 "new_cop"=> {:attachment_type => "cop",
                                                              #:attachment      => fixture_file_upload('files/untitled.pdf', 'application/pdf')},
                                                              :language_id     => Language.first.id}
                                               })
      end
    end
    
    should "be valid when a file is attached" do
      assert_difference 'CommunicationOnProgress.count' do
        cop = create_communication_on_progress(:organization_id    => @organization.id,
                                               :format             => 'standalone',
                                               # :web_based          => false,
                                               :parent_company_cop => false,
                                               :include_continued_support_statement => true,
                                               :support_statement_signee            => 'ceo',
                                               :references_human_rights             => true,
                                               :references_labour                   => true,
                                               :references_environment              => true,
                                               :references_anti_corruption          => true,
                                               :include_measurement                 => true,
                                               :ends_on                             => Date.today,                                             
                                               :cop_files_attributes => {
                                                 "new_cop"=> {:attachment_type => "cop",
                                                              :attachment      => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                                              :language_id     => Language.first.id}
                                               })
      end
    end
      
  end #context
 
  context "given a COP" do
    setup do
      create_organization_and_user
      @cop = pending_review(@organization)
    end
    
    should "change the organization's due date after it is approved" do
      assert_nil @organization.cop_due_on
      
      @cop.approve
      @organization.reload
      assert_equal 1.year.from_now.to_date, @organization.cop_due_on
    end
  end
  
  # context "given a COP in draft mode" do
  #   setup do
  #     create_organization_and_user
  #     @cop = create_communication_on_progress(:organization => @organization, :is_draft => true)
  #   end
  # 
  #   should "save in draft state (not pending_review)" do
  #     assert @cop.draft?
  #   end
  # end
  
  
  # context "given a pending review COP" do
  #   setup do
  #     create_organization_and_user
  #     @cop = pending_review(@organization)
  #   end
  #   
  #   should "be editable" do
  #     assert @cop.editable?
  #   end
  #   
  #   should "not be editable if older than 30 days" do
  #     assert @cop.update_attribute :created_at, 40.days.ago
  #     assert !@cop.editable?
  #   end
  # end
  
  context "given a COP that is a grace letter request and is currently pending review" do
    setup do
      create_organization_and_user('approved')
      @old_cop_due_on = @organization.cop_due_on
      @cop = pending_review(@organization, format: 'grace_letter')
      # @cop = create_communication_on_progress(:organization_id => @organization.id,
      #                                         :cop_files_attributes => {
      #                                           "new_cop"=> {:attachment_type => "cop",
      #                                            :attachment      => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
      #                                            :language_id     => Language.first.id}
      #                                         }
      # )
      @cop.type = 'grace'
      @cop.save
    end
  
    should "have is_grace_letter? return true" do
      assert @cop.is_grace_letter?
    end
    
    # context "and it gets approved" do
    #   setup do
    #     @cop.approve!
    #   end
    #   
    #   should "now be approved" do
    #     assert @cop.approved?
    #   end
      
      should "have an extra 90 days to submit a COP" do
        @organization.reload
        assert_equal (@old_cop_due_on + Organization::COP_GRACE_PERIOD).to_date, (@organization.cop_due_on).to_date
      end
      
      should "set the coverage dates from today until 90 days from now" do
        @cop.reload
        assert_equal Date.today, @cop.starts_on
        assert_equal (Date.today + 90.days), @cop.ends_on
      end
      
  end
    
  context "Given a non-communicating company submitting a grace letter" do
    setup do
      create_organization_and_user
      @organization.update_attribute :cop_state, Organization::COP_STATE_NONCOMMUNICATING
      @cop = pending_review(@organization, format: 'grace_letter')
      @cop.approve!
    end
    
    should "make the company active" do
      @organization.reload
      assert_equal Organization::COP_STATE_ACTIVE, @organization.cop_state
    end
  end
    
  # context "given a COP under review" do
  #   setup do
  #     create_organization_and_user
  #     @cop = create_communication_on_progress(:organization_id => @organization.id,
  #                                             :state           => ApprovalWorkflow::STATE_IN_REVIEW)
  #   end
  # 
  #   should "be editable" do
  #     assert @cop.editable?
  #     assert @cop.update_attribute :created_at, 45.days.ago
  #     assert @cop.reload.editable?
  #   end
  # 
  #   should "not be editable if older than 90 days" do
  #     assert @cop.update_attribute :created_at, 100.days.ago
  #     assert !@cop.editable?
  #   end
  # end
  # 
  # context "given an approved COP" do
  #   setup do
  #     create_organization_and_user
  #     @cop = create_communication_on_progress(:organization_id => @organization.id,
  #                                             :state           => ApprovalWorkflow::STATE_APPROVED)
  #   end
  # 
  #   should "not be editable" do
  #     assert !@cop.editable?
  #   end
  # end
  # 
  # context "given a rejected COP" do
  #   setup do
  #     create_organization_and_user
  #     @cop = create_communication_on_progress(:organization_id => @organization.id,
  #                                             :state           => ApprovalWorkflow::STATE_REJECTED)
  #   end
  # 
  #   should "not be editable" do
  #     assert !@cop.editable?
  #   end
  # end
  # 
  # context "given a COP from a parent company" do
  #   setup do
  #     create_organization_and_user
  #     create_language
  #     @cop = @organization.communication_on_progresses.new(:format             => 'standalone',
  #                                                          :web_based          => true,
  #                                                          :parent_company_cop => true,
  #                                                          :cop_links_attributes => {
  #                                                            "new_link"=> {:attachment_type => "cop",
  #                                                                          :url             => "http://my-cop-online.com",
  #                                                                          :language_id     => Language.first.id}
  #                                                           })
  #   end
  #    
  #   should "be approved if COP covers subsidiary efforts" do
  #     @cop.parent_cop_cover_subsidiary = true
  #     assert @cop.save
  #     assert @cop.reload.approved?
  #   end
  #   
  #   should "be approved if COP doesn't cover subsidiary efforts" do
  #     @cop.parent_cop_cover_subsidiary = false
  #     assert @cop.save
  #     assert @cop.reload.approved?
  #   end
  # end
  
  context "given a COP with its period ending in 2009" do
    setup do
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new({:ends_on => '2009-12-31'})
      @cop.save
    end
      should "title should be Communication on Progress 2009" do
        assert_equal "2009 Communication on Progress", @cop.title
      end
  end
  
  context "given a COP created in 2008" do
    setup do
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new({:ends_on => '2008-12-31'})
      @cop.update_attribute :created_at, Date.new(2008, 12, 31)
    end
    
    should "identify the COP as a legacy format" do
      assert_equal true, @cop.is_legacy_format?
    end    
  end
  
  context "given a COP created in 2012" do
    setup do
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new(:ends_on => Date.new(2012, 12, 31))
      @cop.update_attribute :created_at, Date.new(2012, 01, 01)
    end
    
    should "identify the COP as a new format" do
      assert_equal true, @cop.is_new_format?
    end  
  end
  
  context "given a basic COP" do
    setup do
      create_principle_area
      @cop_question = create_cop_question
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new(:ends_on => Date.today)
      @cop.type = 'basic'
      @cop.save
    end

    should "have default attributes set" do
      assert_equal 'basic', @cop.format
      assert_equal false, @cop.additional_questions
    end

  end
  
  context "given a COP from a delisted company" do
    setup do
      create_organization_and_user
      @organization.update_attribute :cop_state, Organization::COP_STATE_DELISTED
      @organization.update_attribute :active, false
      @cop = pending_review(@organization)
    end
    
    should "change the company's participant and cop status to active" do
      @cop.approve
      @organization.reload
      assert_equal true, @organization.active
      assert_equal Organization::COP_STATE_ACTIVE, @organization.cop_state
    end
  end

end
