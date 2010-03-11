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
#  mentions_partnership_project        :boolean(1)
#  additional_questions                :boolean(1)
#  support_statement_explain_benefits  :boolean(1)
#  missing_principle_explained         :boolean(1)
#  web_based                           :boolean(1)
#

class CommunicationOnProgress < ActiveRecord::Base
  include VisibleTo
  include ApprovalWorkflow

  validates_presence_of :organization_id
  validates_associated :cop_links, :if => Proc.new { |cop| cop.web_based? }
  validates_associated :cop_files, :if => Proc.new { |cop| cop.is_grace_letter? || !cop.web_based? }, :message => ': please upload your COP as a PDF file.'
  
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
  
  before_save :can_be_edited?
  before_create :set_title
  after_create :draft_or_submit!

  accepts_nested_attributes_for :cop_answers
  accepts_nested_attributes_for :cop_files, :allow_destroy => true
  accepts_nested_attributes_for :cop_links, :allow_destroy => true
  
  cattr_reader :per_page
  @@per_page = 15

  default_scope :order => 'created_at DESC'
  
  named_scope :new_policy, {:conditions => ["created_at >= ?", Date.new(2010, 1, 1) ]}
  named_scope :old_policy, {:conditions => ["created_at <= ?", Date.new(2009, 12, 31) ]}
  
  named_scope :for_filter, lambda { |filter_type|
    score_to_find = CopScore.notable if filter_type == :notable
    {
      :include => [:score, {:organization => [:sector, :country]}],
      :conditions => [ "cop_score_id = ?", score_to_find.try(:id) ]
    }
  }
  
  named_scope :by_year, { :order => "end_year DESC, sectors.name ASC, organizations.name ASC" }
  
  FORMAT = {:standalone        => "COP is a stand-alone document",
            :annual_report     => "COP is part of an annual (financial) report",
            :sustainability_report => "COP is part of a sustainability or corporate (social) responsibility report",
            :summary_document  => "COP is a summary document that refers to sections of an annual or sustainability report"}

  SIGNEE = {:ceo       => "Chief Executive Officer (CEO)",
            :board     => "Chairperson or member of Board of Directors",
            :executive => "Other senior executive",
            :none      => "None of the above"}
  
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
  
  def ended_on
    if end_year and end_month
      time = Time.mktime end_year, end_month, 1
      time.to_date
    end
  end
  
  def organization_name
    organization.try :name || ''    
  end
  
  def sector_name
    organization.sector.try(:name) || ''
  end
  
  def started_on
    if start_year and start_month
      time = Time.mktime start_year, start_month, 1
      time.to_date
    end
  end
  
  def urls
    [url1, url2, url3].compact
  end
  
  def year
    end_year
  end
  
  def init_cop_attributes
    CopQuestion.questions_for(self.organization).each {|cop_question|
      cop_question.cop_attributes.each {|cop_attribute|
        self.cop_answers.build(:cop_attribute_id => cop_attribute.id,
                               :value            => false)
        }
    }
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
        # automatic_decision
      end
    end
  end
  
  def is_grace_letter?
    # FIXME: self.format was throwing an exception
    self.attributes['format'] == CopFile::TYPES[:grace_letter]
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
  
  # COPs may be automatically approved
  def automatic_decision
    approve and return if is_grace_letter?
    if parent_company_cop?
      if parent_cop_cover_subsidiary?
        approve
      else
        reject
      end
      return
    end
    if organization.joined_after_july_2009?
      if organization.participant_for_over_5_years?
        # participant for more than 5 years who joined after July 1st 2009
        if (score == 4 && include_measurement?) || (score == 3 && include_measurement? && missing_principle_explained?)
          approve
        else
          reject
        end
      else
        # participant for less than 5 years who joined after July 1st 2009
        (score >= 2 && include_measurement?) ? approve : reject
      end
    else
      if organization.participant_for_over_5_years?
        # participant for more than 5 years who joined before July 1st 2009
        if (score == 4 && include_measurement?) || (score == 3 && include_measurement? && missing_principle_explained?)
          approve
        else
          reject
        end
      else
        # participant for less than 5 years who joined before July 1st 2009
        (score >= 1 && include_measurement?) ? approve! : reject!
      end
    end
  end
  
  # Calculate COP score based on answers to Q7
  def score
    [references_labour,
      references_human_rights,
      references_anti_corruption,
      references_environment].collect{|r| r if r}.compact.count
  end
  
  def set_title
    if is_grace_letter?
      self.title = "Grace Letter"
    else
      self.title = "#{Date.today.year} Communication on Progress"
    end
  end
end
