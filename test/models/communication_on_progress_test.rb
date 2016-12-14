require 'test_helper'

class CommunicationOnProgressTest < ActiveSupport::TestCase
  should validate_presence_of :organization_id
  should validate_presence_of :title
  should belong_to :organization
  should have_and_belong_to_many :languages
  should have_and_belong_to_many :countries
  should have_and_belong_to_many :principles
  should have_many :cop_answers
  should have_many :cop_files

  context "given a new COP" do
    setup do
      create_organization_and_user
      create(:language)
    end

    should "be invalid if there is no file" do
      assert_raise ActiveRecord::RecordInvalid do
        create(:communication_on_progress,
          :organization_id    => @organization.id,
          :title              => 'Our COP',
          :format             => 'standalone',
          :include_continued_support_statement => true,
          :references_human_rights             => true,
          :references_labour                   => true,
          :references_environment              => true,
          :references_anti_corruption          => true,
          :include_measurement                 => true,
          :ends_on                             => Date.today,
          :cop_files_attributes => {
            "new_cop"=> {
              :attachment_type => "cop",
              :language_id     => Language.first.id}
            }
          )
      end
    end

    should "be valid when a file is attached" do
      assert_difference 'CommunicationOnProgress.count' do
        create(:communication_on_progress,
          :organization_id                     => @organization.id,
          :title                               => 'Our COP',
          :format                              => 'standalone',
          :include_continued_support_statement => true,
          :references_human_rights             => true,
          :references_labour                   => true,
          :references_environment              => true,
          :references_anti_corruption          => true,
          :include_measurement                 => true,
          :ends_on                             => Date.today,
          :cop_files_attributes => {
          "new_cop"=> {
            :attachment_type => "cop",
            :attachment      => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
            :language_id     => Language.first.id}
          }
        )
      end
    end

  end

  context "given a COP" do
    setup do
      create_organization_and_user
      @cop = generate_cop(@organization)
    end

    should "change the organization's due date after it is approved" do
      @cop.approve
      @organization.reload
      assert_equal 1.year.from_now.to_date, @organization.cop_due_on
    end
  end

  context "given a COP from a non-business" do
    setup do
      create_non_business_organization_and_user
      @cop = generate_cop(@organization)
    end

    should "set the email template to the non-business version" do
      assert_equal 'non_business', @cop.confirmation_email
    end

    should "change the organization's due date two years after it is approved" do
      @cop.approve
      @organization.reload
      assert_equal 2.year.from_now.to_date, @organization.cop_due_on
    end

  end

  context "given a COP that is a grace letter" do
    setup do
      create_organization_and_user('approved')
      @organization.communication_late
      @cop = generate_cop(@organization, format: 'grace_letter', :title => 'Grace Letter')
      @cop.cop_type = 'grace'
      @cop.save
      @cop.reload
      @organization.reload
    end

    should "have is_grace_letter? return true" do
      assert @cop.is_grace_letter?
    end

    should "have the title 'Grace Letter'" do
      assert_equal @cop.title, 'Grace Letter'
    end

    should "not be evaluated for differentiation" do
      assert_equal '', @cop.differentiation_level
      assert_equal '', @cop.differentiation
    end

  end

  context "Given a non-communicating company submitting a grace letter" do
    setup do
      create_organization_and_user
      @organization.communication_late
    end

    should "keep the company Non-communicating if passed grace period" do
      @organization.update_attribute :cop_due_on, Date.today - 91.days
      @cop = generate_cop(@organization, format: 'grace_letter')
      @organization.reload
      assert_equal Organization::COP_STATE_NONCOMMUNICATING, @organization.cop_state
    end

    should "keep the company Non-communicating even if within grace period" do
      @organization.update_attribute :cop_due_on, Date.today - 89.days
      @cop = generate_cop(@organization, format: 'grace_letter')
      @organization.reload
      assert_equal Organization::COP_STATE_NONCOMMUNICATING, @organization.cop_state
    end

  end

  context "given an approved COP" do
    setup do
      create(:language)
      create_organization_and_user
      @cop = create(:communication_on_progress, :organization_id => @organization.id,
                                              :cop_files_attributes => {
                                                 "new_cop"=> {:attachment_type => "cop",
                                                              :attachment      => fixture_file_upload('files/untitled.pdf', 'application/pdf'),
                                                              :language_id     => Language.first.id} },
                                              :state => ApprovalWorkflow::STATE_APPROVED)
    end

    should "be editable" do
      assert @cop.editable?
    end

    should "have a file attached" do
      assert_equal 1, @cop.cop_files.count
    end

     should "remove file when COP is deleted" do
       assert_difference "CopFile.count", -1 do
         @cop.destroy
       end
     end

  end

  context "given a COP created in 2008" do
    setup do
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new({:title => 'Our COP', :ends_on => '2008-12-31'})
      @cop.update_attribute :created_at, Date.new(2008, 12, 31)
    end

    should "identify the COP as a legacy format" do
      assert_equal true, @cop.is_legacy_format?
    end
  end

  context "given a COP created in 2012" do
    setup do
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new(:title => 'Our COP', :ends_on => Date.new(2012, 12, 31))
      @cop.update_attribute :created_at, Date.new(2012, 01, 01)
    end

    should "identify the COP as a new format" do
      assert_equal true, @cop.is_new_format?
    end
  end

  context "given a basic COP" do
    setup do
      create(:principle_area)
      @cop_question = create(:cop_question)
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new(:title => 'Our COP', :ends_on => Date.today)
      @cop.cop_type = 'basic'
      @cop.save
    end

    should "have default attributes set" do
      assert_equal 'basic', @cop.format
      assert_equal false, @cop.additional_questions
    end

  end

  context "given a COP with additional questions" do
    setup do
      create_organization_and_user
      @cop = @organization.communication_on_progresses.new( :title => 'Our COP',
                                                            :ends_on => Date.today)
      @cop.cop_type = 'advanced'

      # 6 required criteria to be considered Active
      @cop.update_attribute :include_continued_support_statement, true
      @cop.update_attribute :include_measurement, true
      @cop.update_attribute :references_labour, true
      @cop.update_attribute :references_human_rights, true
      @cop.update_attribute :references_anti_corruption, true
      @cop.update_attribute :references_environment, true
      @cop.save
    end

    should "be considered Learner if they are missing one of the 6 criteria" do
      learner_policy = CommunicationOnProgress::LearnerPolicy.new(@organization)
      @cop.update_attribute :references_environment, false
      assert_equal 'learner', @cop.differentiation
      assert @cop.learner?
      assert learner_policy.last_cop_is_learner?
    end

  end

  context "given a COP from a delisted company" do
    setup do
      create_organization_and_user
      @organization.update_attribute :cop_state, Organization::COP_STATE_DELISTED
      @organization.update_attribute :active, false
    end

    should "change the company's participant and cop status to active" do
      @cop = generate_cop(@organization)
      @organization.reload
      assert_equal true, @organization.active
      assert_equal Organization::COP_STATE_ACTIVE, @organization.cop_state
      assert_equal Date.today, @organization.rejoined_on
    end
  end

  context "given a COP. By default it " do
    setup do
      create_organization_and_user
      @cop = create(:communication_on_progress)
    end

    should "not meet advanced criteria" do
      refute @cop.meets_advanced_criteria
    end
  end

  test "#answered_all_questions? ignores exempted groups" do
    # Given 2 questions exist for the advanced form:
    # One for the SDG group, which is exempted
    sdg_question = create(:cop_question, grouping: 'sdgs')

    # One for UN Goals, which is not exempted
    un_goals_question = create(:cop_question, grouping: 'un_goals')

    # And 2 true/false Attributes for each question
    sdg_attributes = create_list(:cop_attribute, 2,
                                 cop_question: sdg_question,
                                 open: false)

    un_goals_attributes = create_list(:cop_attribute, 2,
                                      cop_question: un_goals_question,
                                      open: false)

    # When a participant creates a COP
    cop = create(:communication_on_progress)

    # Answering both UN Goal Attributes
    un_goals_attributes.each do |attribute|
      create(:cop_answer,
             communication_on_progress: cop,
             cop_attribute: attribute,
             value: true)
    end

    # And neither of the SDG ones (answering them in the negative)
    sdg_attributes.each do |attribute|
      create(:cop_answer,
             communication_on_progress: cop,
             cop_attribute: attribute,
             value: false)
    end

    # Then they should still be have answered_all_questions
    assert cop.answered_all_questions?, unanswered_questions(cop.empty_answers)
  end

  private

  def unanswered_questions(empty_answers)
    empty_answers.flat_map(&:cop_attribute).flat_map(&:cop_question)
  end

  def generate_cop(organization, options={})
    defaults = {
      :organization_id => organization.id,
      :ends_on         => Date.new(2009, 12, 31)
    }
    create(:communication_on_progress, defaults.merge(options))
  end

end
