# == Schema Information
#
# Table name: communication_on_progresses
#
#  id                                  :integer          not null, primary key
#  organization_id                     :integer
#  title                               :string(255)
#  email                               :string(255)
#  job_title                           :string(255)
#  contact_name                        :string(255)
#  include_actions                     :boolean
#  include_measurement                 :boolean
#  use_indicators                      :boolean
#  cop_score_id                        :integer
#  use_gri                             :boolean
#  has_certification                   :boolean
#  notable_program                     :boolean
#  created_at                          :datetime
#  updated_at                          :datetime
#  description                         :text
#  state                               :string(255)
#  include_continued_support_statement :boolean
#  format                              :string(255)
#  references_human_rights             :boolean
#  references_labour                   :boolean
#  references_environment              :boolean
#  references_anti_corruption          :boolean
#  meets_advanced_criteria             :boolean
#  additional_questions                :boolean
#  starts_on                           :date
#  ends_on                             :date
#  method_shared                       :string(255)
#  differentiation                     :string(255)
#  references_business_peace           :boolean
#  references_water_mandate            :boolean
#

class CommunicationOnProgress < ActiveRecord::Base
  include VisibleTo
  include ApprovalWorkflow

  validates_presence_of :organization_id, :title
  validates_associated :cop_links
  validates_associated :cop_files

  belongs_to :organization
  belongs_to :score, :class_name => 'CopScore', :foreign_key => :cop_score_id
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :principles
  has_many :cop_answers, :foreign_key => :cop_id
  has_many :cop_attributes, :through => :cop_answers
  has_many :cop_files, :foreign_key => :cop_id
  has_many :cop_links, :foreign_key => :cop_id
  acts_as_commentable

  before_create  :check_links
  before_save    :set_cop_defaults
  before_save    :can_be_edited?
  after_create   :set_differentiation_level
  after_create   :set_approved_state
  before_destroy :delete_associated_attributes

  accepts_nested_attributes_for :cop_answers
  accepts_nested_attributes_for :cop_files, :allow_destroy => true
  accepts_nested_attributes_for :cop_links, :allow_destroy => true

  cattr_reader :per_page
  @@per_page = 15

  TYPES = %w{grace basic intermediate advanced lead non_business}

  default_scope :order => 'communication_on_progresses.created_at DESC'

  scope :all_cops, includes([:organization, {:organization => [:country]}])
  scope :created_between, lambda { |start_date, end_date| where(created_at: start_date..end_date) }
  scope :new_policy, lambda { where("created_at >= ?", Date.new(2010, 1, 1)) }
  scope :old_policy, lambda { where("created_at <= ?", Date.new(2009, 12, 31)) }
  scope :notable, lambda {
    includes([:score, {:organization => [:country]}]).where("cop_score_id = ?", CopScore.notable.try(:id)).order("ends_on DESC")
  }
  scope :active,   where("differentiation = ?", 'active').includes([{:organization => [:country, :sector]}])
  scope :advanced, where("differentiation IN (?)", ['advanced','blueprint']).includes([{:organization => [:country, :sector]}])
  scope :learner, where("differentiation = ?", 'learner').includes([{:organization => [:country, :sector]}])
  scope :since_year, lambda { |year| where("created_at >= ?", Date.new(year, 01, 01)).includes([ :organization, {:organization => :country, :organization => :organization_type}]) }
  # feed contains daily COP submissions, without grace letters
  scope :for_feed, lambda { where("format != ? AND created_at >= ?", 'grace_letter', Date.today).order("created_at") }
  scope :by_year, order("communication_on_progresses.created_at DESC, sectors.name ASC, organizations.name ASC")

  FORMAT = {:standalone            => "Stand alone document",
            :sustainability_report => "Part of a sustainability or corporate (social) responsibility report",
            :annual_report         => "Part of an annual (financial) report"
           }

  LEVEL_DESCRIPTION = { :blueprint => "This COP qualifies for the Global Compact Advanced level",
                        :advanced  => "This COP qualifies for the Global Compact Advanced level",
                        :active    => "This COP qualifies for the Global Compact Active level",
                        :learner   => "This COP places the participant on the Global Compact Learner Platform"
                      }

  START_DATE_OF_DIFFERENTIATION  = Date.new(2011, 01, 29)
  START_DATE_OF_LEAD_BLUEPRINT   = Date.new(2012, 01, 01)
  START_DATE_OF_ADVANCED_LEAD    = Date.new(2013, 03, 01)
  START_DATE_OF_NON_BUSINESS_COE = Date.new(2013, 10, 31)

  def self.find_by_param(param)
    return nil if param.blank?
    if param =~ /\A(\d\d+).*/
      find_by_id param.to_i
    else
      param = CGI.unescape param
      where("title = ?", param).first
    end
  end

  def country_name
    organization.try(:country).try(:name)
  end

  def organization_id
    organization.try :id || ''
  end

  def organization_name
    organization.try :name || ''
  end

  def organization_joined_on
    organization.try :joined_on || ''
  end

  def organization_type
    organization.try :organization_type_name || ''
  end

  def organization_cop_state
    organization.try :cop_state || ''
  end

  def sector_name
    organization.sector.try(:name) || ''
  end

  def year
    ends_on.strftime('%Y')
  end

  def cop_questions
    @questions ||= CopQuestion.questions_for(self.organization)
  end

  def cop_questions_for_grouping(grouping, options)
    principle_area  = PrincipleArea.send(options[:principle]) if options[:principle]
    conditions = {
      :principle_area_id => principle_area.try(:id),
      :grouping          => grouping.to_s,
      :year              => options[:year]
    }

    cop_questions.select do |question|
      conditions.all? { |key, val| question.send(key) == val }
    end
  end

  def is_legacy_format?
    created_at <= Date.new(2009, 12, 31)
  end

  def is_new_format?
    new_record? || created_at >= Date.new(2010, 01, 01)
  end

  # Official launch of Differentiation Programme was January 28, 2011
  def is_advanced_programme?
    if additional_questions
      new_record? || created_at > START_DATE_OF_DIFFERENTIATION
    end
  end

  def is_differentiation_program?
    created_at >= START_DATE_OF_DIFFERENTIATION && !is_grace_letter?
  end

  # Test phase of Advanced Programme was launched Oct 11, 2010
  # Only those submitting after this date are actually considered to be participating in the programme
  # However, participants could answer the additional voluntary questions prior to this date
  def is_test_phase_advanced_programme?
    additional_questions && created_at >= Date.new(2010, 10, 11) && created_at <= START_DATE_OF_DIFFERENTIATION
  end

  # Advanced and LEAD formats were combined in 2013
  def is_advanced_lead?
    created_at >= START_DATE_OF_ADVANCED_LEAD
  end

  def is_grace_letter?
    # self.format does not work since 'format' is a reserved keyword in MySQL
    self.attributes['format'] == CopFile::TYPES[:grace_letter]
  end

  def is_reporting_cycle_adjustment?
    # TOOD to be completed with submission process
    false
  end

  def is_non_business_format?
    created_at >= START_DATE_OF_NON_BUSINESS_COE && organization.non_business?
  end

  def is_basic?
    is_new_format? && self.attributes['format'] == 'basic'
  end

  # XXX remove this method
  # editing is always enabled now
  def editable?
    true
  end

  def set_approved_fields
    if !is_grace_letter? && !is_reporting_cycle_adjustment?
      organization.set_next_cop_due_date_and_cop_status
    end
  end


  # Calculate COP score based on answers to Q7
  def score
    [references_labour,
      references_human_rights,
      references_anti_corruption,
      references_environment].collect{|r| r if r}.compact.count
  end

  def number_missing_items
    items = [ include_continued_support_statement,
              references_labour,
              references_human_rights,
              references_anti_corruption,
              references_environment,
              include_measurement ]
    items.count - items.collect{|r| r if r}.compact.count
  end

  def missing_items?
    number_missing_items > 0
  end

  def issue_areas_covered
    issues = []
    PrincipleArea::FILTERS.each_pair do |key, value|
      issues << value if self.send("references_#{key}?")
    end
    issues
  end

  # Calculate % of items covered for each issue area
  # Grouping is usually 'additional'
  def issue_area_coverage(principle_area_id, grouping)

    question_count = CopAnswer.find_by_sql(
    ["SELECT count(answers.cop_id) AS question_count FROM cop_attributes attributes
      JOIN cop_answers answers
      ON answers.cop_attribute_id = attributes.id
      WHERE answers.cop_id = ? AND cop_question_id IN (
        SELECT id FROM cop_questions
        WHERE principle_area_id = ? AND grouping = ?)", self.id, principle_area_id.to_i, grouping.to_s]
    )

    answer_count = CopAnswer.find_by_sql(
    ["SELECT count(answers.cop_id) AS answer_count FROM cop_attributes attributes
      JOIN cop_answers answers
      ON answers.cop_attribute_id = attributes.id
      WHERE answers.cop_id = ? AND answers.value = ? AND cop_question_id IN (
        SELECT id FROM cop_questions
        WHERE principle_area_id = ? AND grouping = ?)", self.id, true, principle_area_id.to_i, grouping.to_s]
    )

    [answer_count.first.answer_count, question_count.first.question_count]
  end

  # number of attributes selected for a question
  def number_question_attributes_covered(cop_attribute_id)
    answer_count = CopAnswer.find_by_sql(
    ["SELECT sum(value) AS total FROM cop_answers
      JOIN cop_attributes
      ON cop_answers.cop_attribute_id = cop_attributes.id
      WHERE cop_answers.cop_id = ? AND cop_question_id = ?", self.id, cop_attribute_id]
    )
    answer_count.first.total.to_i
  end

  # gather questions based on submitted attributes
  def answered_questions(grouping = nil)

    if grouping
      CopQuestion.group_by(grouping).all(:conditions => ["id IN (?)", cop_attributes.collect(&:cop_question_id)])
    else
      questions = []
      cop_attributes.each do |attribute|
        # don't evaluate coverage of exempted groups
        questions << attribute.cop_question unless CopQuestion::EXEMPTED_GROUPS.include? attribute.cop_question.grouping
      end
      questions
    end

  end

  # questions with no selected attributes
  def questions_missing_answers
    missing = []
    answered_questions.each do |question|
      missing << question.id if number_question_attributes_covered(question.id) == 0
    end
    CopQuestion.find(missing)
  end

  # get specific cop_answers not answered for a particular COP Question group
  def missing_answers_for_group(grouping)
    cop_answers.not_covered_by_group(grouping)
  end

  def evaluated_for_differentiation?
    if is_grace_letter? || is_non_business_format?
      false
    else
      new_record? || created_at > START_DATE_OF_DIFFERENTIATION
    end
  end

  # as defined in COP Policy, these are the minimum requirements for an acceptable (Active Level) COP
  # only those that submitted after the start of the differentiation program can be counted
  def is_intermediate_level?
    evaluated_for_differentiation? &&
    include_continued_support_statement &&
    include_measurement &&
    issue_areas_covered.count == 4
  end

  # for the COP to be Advanced, cop questions cannot have any missing cop_attributes
  def is_advanced_level?
    if questions_missing_answers.any?
      self.meets_advanced_criteria = false
    else
      self.meets_advanced_criteria = true
    end
    is_advanced_programme? && is_intermediate_level? && meets_advanced_criteria
  end

  def is_blueprint_level?
    (new_record? || created_at > START_DATE_OF_LEAD_BLUEPRINT) &&
    organization.signatory_of?(:lead) &&
    evaluated_for_differentiation?
  end

  def differentiation_level
    if is_advanced_level?
      :advanced
    elsif is_intermediate_level?
      :active
    elsif evaluated_for_differentiation?
      :learner
    else
      ''
    end
  end

  # blueprint refers to advanced COPs from LEAD companies and will is only used for internal purposes
  def differentiation_level_public
    differentiation == 'blueprint' ? 'advanced' : differentiation
  end

  def learner?
    differentiation == 'learner'
  end

  def advanced?
    differentiation == 'advanced'
  end

  def blueprint?
    differentiation == 'blueprint'
  end

  def is_reporting_adjustment?
    false # for now.
  end

  def missing_lead_criteria?
    unless is_grace_letter? || is_reporting_adjustment?
      !['advanced','blueprint'].include?(differentiation)
    end
  end

  def differentiation_level_name
    differentiation.to_s.try(:humanize)
  end

  def differentiation_description
    LEVEL_DESCRIPTION[differentiation.to_sym]
  end

  def organization_business_entity?
    organization.business_entity?
  end

  def confirmation_email
    if organization_business_entity?
      if organization.triple_learner_for_one_year?
        'triple_learner_for_one_year'
      elsif organization.double_learner?
        'double_learner'
      elsif organization.signatory_of?(:lead)
        'blueprint'
      else
        differentiation
      end
    else
      'non_business'
    end
  end

  def latest?
    self == organization.communication_on_progresses.first
  end

  def readable_error_messages
    error_messages = []
    errors.each do |attribute|
      case attribute.to_s
        when 'cop_files.attachment_file_name'
          error_messages << 'Choose a file to upload'
        when 'cop_files.language'
          error_messages << 'Select a language for each file'
        when 'cop_links.url'
          error_messages << 'Please make sure your link begins with \'http://\''
        when 'cop_links.language'
          error_messages << 'Select a language for each link'
       end
    end
    error_messages
  end

  private

    # javascript will normally hide the link field if it's blank,
    # but IE7 was not cooperating, so we double check
    def check_links
      self.cop_links.each do |link|
        link.destroy if link.url.blank?
      end
    end

    def set_cop_defaults
      self.additional_questions = false
      case cop_type
        when 'basic'
          self.format = 'basic'
        when 'advanced'
          self.additional_questions = true
        when 'lead'
          self.additional_questions = true
      end
    end

    def can_be_edited?
      unless editable?
        errors.add :base, ("You can no longer edit this COP. Please, submit a new one.")
      end
    end

    # record level in case the criteria changes in the future
    def set_differentiation_level
      update_attribute :differentiation, differentiation_level.to_s
    end

    # set approved state for all COPs
    def set_approved_state
      update_attribute(:state, "approved")
      set_approved_fields
    end

    def delete_associated_attributes
      cop_files.each {|file| file.destroy}
      cop_links.each {|link| link.destroy}
      cop_answers.each {|answer| answer.destroy}
    end

end
