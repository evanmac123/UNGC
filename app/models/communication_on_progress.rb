# == Schema Information
#
# Table name: communication_on_progresses
#
#  id                                  :integer(4)      not null, primary key
#  identifier                          :string(255)
#  organization_id                     :integer(4)
#  title                               :string(255)
#  related_document                    :string(255)
#  email                               :string(255)
#  start_year                          :integer(4)
#  facilitator                         :string(255)
#  job_title                           :string(255)
#  start_month                         :integer(4)
#  end_month                           :integer(4)
#  url1                                :string(255)
#  url2                                :string(255)
#  url3                                :string(255)
#  added_on                            :date
#  modified_on                         :date
#  contact_name                        :string(255)
#  end_year                            :integer(4)
#  status                              :integer(4)
#  include_ceo_letter                  :boolean(1)
#  include_actions                     :boolean(1)
#  include_measurement                 :boolean(1)
#  use_indicators                      :boolean(1)
#  cop_score_id                        :integer(4)
#  use_gri                             :boolean(1)
#  has_certification                   :boolean(1)
#  notable_program                     :boolean(1)
#  created_at                          :datetime
#  updated_at                          :datetime
#  description                         :text
#  state                               :string(255)
#  include_continued_support_statement :boolean(1)
#  format                              :string(255)
#  references_human_rights             :boolean(1)
#  references_labour                   :boolean(1)
#  references_environment              :boolean(1)
#  references_anti_corruption          :boolean(1)
#  replied_to                          :boolean(1)
#  reviewer_id                         :integer(4)
#  support_statement_signee            :string(255)
#  parent_company_cop                  :boolean(1)
#  parent_cop_cover_subsidiary         :boolean(1)
#  meets_advanced_criteria             :boolean(1)
#  additional_questions                :boolean(1)
#  support_statement_explain_benefits  :boolean(1)
#  missing_principle_explained         :boolean(1)
#  is_shared_with_stakeholders         :boolean(1)
#  starts_on                           :date
#  ends_on                             :date
#  method_shared                       :string(255)
#  differentiation                     :string(255)
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

  attr_accessor :is_draft
  attr_accessor :policy_exempted
  attr_accessor :type

  before_create  :check_links
  before_save    :set_cop_defaults
  before_save    :set_differentiation_level
  before_save    :can_be_edited?
  after_create   :draft_or_submit!
  before_destroy :delete_associated_attributes

  accepts_nested_attributes_for :cop_answers
  accepts_nested_attributes_for :cop_files, :allow_destroy => true
  accepts_nested_attributes_for :cop_links, :allow_destroy => true

  cattr_reader :per_page
  @@per_page = 15

  TYPES = %w{grace basic intermediate advanced lead}

  default_scope :order => 'created_at DESC'

  named_scope :all_cops,   {:include => [ :organization, { :organization => :country } ]}

  named_scope :local_networks_all_cops, lambda { |org_scope| {
    :include => [ :organization, { :organization => :country } ],
    :conditions => org_scope
    }
  }

  named_scope :new_policy, {:conditions => ["created_at >= ?", Date.new(2010, 1, 1) ]}
  named_scope :old_policy, {:conditions => ["created_at <= ?", Date.new(2009, 12, 31) ]}

  named_scope :notable, {
    :include => [:score, {:organization => [:country]}],
    :conditions => [ "cop_score_id = ?", CopScore.notable.try(:id) ],
    :order => 'ends_on DESC'
  }

  named_scope :advanced, {
    :include => [ {:organization => [:country, :sector]} ],
    :conditions => [ "differentiation IN (?)", ['advanced','blueprint'] ]
  }

  named_scope :learner, {
    :include => [ {:organization => [:country, :sector]} ],
    :conditions => [ "differentiation = ?", 'learner' ]
  }

  named_scope :by_year, { :order => "communication_on_progresses.created_at DESC, sectors.name ASC, organizations.name ASC" }

  named_scope :since_year, lambda { |year| {
    :include => [ :organization, { :organization => :country,
                                   :organization => :organization_type } ],
    :conditions => ["created_at >= ?", Date.new(year, 01, 01) ]
    }
  }

  # feed contains daily COP submissions, without grace letters
  named_scope :for_feed, {
    :conditions => ["format != (?) AND created_at >= (?)", 'grace_letter', Date.today],
    :order => "created_at DESC"
  }

  FORMAT = {:standalone            => "Stand alone document",
            :sustainability_report => "Part of a sustainability or corporate (social) responsibility report",
            :annual_report         => "Part of an annual (financial) report"

           }

  # How the COP is shared
  METHOD = {:gc_website   => "a) Through the UN Global Compact website only",
            :all_access   => "b) COP is easily accessible to all interested parties (e.g. via its website)",
            :stakeholders => "c) COP is actively distributed to all key stakeholders (e.g. investors, employees, consumers, local community)",
            :all          => "d) Both b) and c)"
           }

  # Basic COP templates have other options for sharing their COP
  BASIC_METHOD = {:gc_website   => "a) On the UN Global Compact website only",
                  :all_access   => "b) COP will be made easily accessible to all interested parties on company website",
                  :stakeholders => "c) COP will be actively distributed to all key stakeholders (e.g. investors, employees, consumers, local community)",
                  :all          => "d) Both b) and c)"
                 }

  LEVEL_DESCRIPTION = { :blueprint => "This COP qualifies for the Global Compact Advanced level",
                        :advanced  => "This COP qualifies for the Global Compact Advanced level",
                        :active    => "This COP qualifies for the Global Compact Active level",
                        :learner   => "This COP places the participant on the Global Compact Learner Platform"
                      }

  START_DATE_OF_DIFFERENTIATION = Date.new(2011, 01, 29)
  START_DATE_OF_LEAD_BLUEPRINT = Date.new(2012, 01, 01)

  def self.find_by_param(param)
    return nil if param.blank?
    if param =~ /\A(\d\d+).*/
      find_by_id param.to_i
    else
      param = CGI.unescape param
      find :first, :conditions => ["title = ?", param]
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

  def urls
    [url1, url2, url3].compact
  end

  def year
    ends_on.strftime('%Y')
  end

  def init_cop_attributes
    CopQuestion.questions_for(self.organization).each {|cop_question|
      cop_question.cop_attributes.each {|cop_attribute|
        self.cop_answers.build(:cop_attribute_id => cop_attribute.id,
                               :value            => false,
                               :text             => nil)
        }
    }
  end

  def set_cop_defaults
    self.additional_questions = false
    case self.type
      when 'grace'
        self.format = CopFile::TYPES[:grace_letter]
        self.title = 'Grace Letter'
        # normally they can choose the coverage dates, but for grace letters it matches the grace period
        self.starts_on = self.organization.cop_due_on
        self.ends_on = self.organization.cop_due_on + Organization::COP_GRACE_PERIOD.days
      when 'basic'
        self.format = 'basic'
      when 'advanced'
        self.additional_questions = true
      when 'lead'
        self.additional_questions = true
        self.meets_advanced_criteria = true
    end
  end

  def can_be_edited?
    unless self.editable?
      errors.add_to_base("You can no longer edit this COP. Please, submit a new one.")
    end
  end

  # move COP to draft state
  def draft_or_submit!
    return true unless initial? # tests might setup COPs with state pre-set
    if self.is_draft
      save_as_draft!
      organization.extend_cop_temporary_period
    else
      if can_submit?
        submit!
        approve
      end
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

  def is_grace_letter?
    # FIXME: self.format was throwing an exception
    self.attributes['format'] == CopFile::TYPES[:grace_letter]
  end

  def is_basic?
    is_new_format? && self.attributes['format'] == 'basic'
  end

  # Indicated whether this COP is editable
  def editable?
    # TODO use the new pre-pending state here
    return true if self.new_record?
    if self.pending_review?
      self.created_at + 30.days >= Time.now
    elsif self.in_review?
      self.created_at + 90.days >= Time.now
    else
      false
    end
  end

  def set_approved_fields
    if is_grace_letter?
      organization.extend_cop_grace_period
    else
      organization.set_next_cop_due_date
    end
  end

  # javascript will normally hide the link field if it's blank,
  # but IE7 was not cooperating, so we double check
  def check_links
    self.cop_links.each do |link|
      link.destroy if link.url.blank?
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
      # don't include LEAD questions
      questions = []
      cop_attributes.each do |a|
        questions << a.cop_question unless Initiative.for_filter(:lead).include? a.cop_question.initiative
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

  # questions that do not have all attributes selected
  def questions_not_fully_covered(grouping = nil)
    missing = []
    answered_questions(grouping).each do |question|
      missing << question.id if question.cop_attributes.count > number_question_attributes_covered(question.id)
    end
    CopQuestion.find(missing)
  end

  # get specific cop_answers not answered for a particular COP Question group
  def missing_answers_for_group(grouping)
    cop_answers.not_covered_by_group(grouping)
  end

  def lead_cop_is_incomplete?
    is_blueprint_level? &&
      questions_missing_answers.any? ||
      questions_not_fully_covered('lead_un_goals').any? ||
      questions_not_fully_covered('lead_gc').any?
  end

  def evaluated_for_differentiation?
    if is_grace_letter?
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

  # those that have also self-declared themeselves as meeting the advanced critera (yes/no)
  def is_advanced_level?
    is_advanced_programme? && is_intermediate_level? && meets_advanced_criteria
  end

  def is_blueprint_level?
    (new_record? || created_at > START_DATE_OF_LEAD_BLUEPRINT) &&
    organization.signatory_of?(:lead) &&
    evaluated_for_differentiation?
  end

  def differentiation_level
    if is_blueprint_level?
      :blueprint
    elsif is_advanced_level?
      :advanced
    elsif is_intermediate_level?
      :active
    elsif evaluated_for_differentiation?
      :learner
    else
      ''
    end
  end

  def learner?
    differentiation == 'learner'
  end

  def differentiation_level_name
    differentiation.to_s.try(:humanize)
  end

  def differentiation_description
    LEVEL_DESCRIPTION[differentiation_level]
  end

  # record level in case the criteria changes in the future
  def set_differentiation_level
    self.differentiation = differentiation_level.try(:to_s)
  end

  def organization_business_entity?
    organization.business_entity?
  end

  def confirmation_email
    if organization_business_entity?

      if organization.double_learner?
        'double_learner'
      else
        differentiation_level
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
    errors.each do |error|
      case error
        when 'cop_files.attachment'
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

    def delete_associated_attributes
      self.cop_files.each {|file| file.destroy}
      self.cop_links.each {|link| link.destroy}
      self.cop_answers.each {|answer| answer.destroy}
    end

end
