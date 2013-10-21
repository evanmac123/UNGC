# == Schema Information
#
# Table name: cop_questions
#
#  id                :integer          not null, primary key
#  principle_area_id :integer
#  text              :string(255)
#  position          :integer
#  created_at        :datetime
#  updated_at        :datetime
#  initiative_id     :integer
#  grouping          :string(255)
#  implementation    :string(255)
#  year              :integer
#

class CopQuestion < ActiveRecord::Base

  FIRST_YEAR = 2010
  LAST_YEAR = Time.now.year + 1
  YEAR_RANGE = FIRST_YEAR..LAST_YEAR

  validates_presence_of :text, :grouping
  has_many :cop_attributes
  belongs_to :principle_area
  belongs_to :initiative

  accepts_nested_attributes_for :cop_attributes, :allow_destroy => true,
                                                 :reject_if     => proc { |a| a['text'].blank? }

  # optionally group questions so they can be displayed together
  # basic is used for Basic COP where the responses are in text format
  GROUPING_AREAS = {
    'additional'           => 'Additional',
    'basic'                => 'Basic Template',
    'strategy'             => 'Strategy, Governance and Engagement',
    'un_goals'             => 'UN Goals and Issues',
    'value_chain'          => 'Value Chain Implementation',
    'verification'         => 'Verification and Transparency',
    'governance'           => 'Governance',
    'lead_un_goals'        => 'LEAD: UN Goals',
    'lead_gc'              => 'LEAD: Global Compact',
    'mandatory'            => 'Mandatory',
    'notable'              => 'Notable',
    'business_peace'       => 'Business and Peace',
    'academic'             => 'Non-Business: Academic',
    'business_association' => 'Non-Business: Business Association',
    'city'                 => 'Non-Business: City',
    'labour'               => 'Non-Business: Labour',
    'ngo'                  => 'Non-Business: NGO',
    'public'               => 'Non-Business: Public Sector Organization'
  }

  # for accessing particular grouping areas
  ADVANCED_GROUPS = ['additional', 'strategy', 'un_goals', 'verification', 'governance']
  LEAD_GROUPS     = ['lead_un_goals', 'lead_gc']

  # at least one cop_attribute must be covered per cop_question, unless the grouping area is exempted
  EXEMPTED_GROUPS = ['business_peace', 'mandatory']

  # can optionally select the implementation area the question covers
  IMPLEMENTATION_AREAS =  ['policy', 'process', 'monitoring', 'performance']

  default_scope :order => 'cop_questions.position'
  scope :general, where("initiative_id IS NULL")
  scope :initiative_questions_for, lambda { |organization| where('initiative_id IN (?)', organization.initiative_ids) }

  scope :questions_for, lambda { |organization| where('(initiative_id IS NULL) OR (initiative_id IN (?))', organization.initiative_ids) }
  scope :group_by, lambda { |group| where('grouping = ?', group.to_s) }

end
