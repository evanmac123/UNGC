# == Schema Information
#
# Table name: cop_questions
#
#  id                :integer(4)      not null, primary key
#  principle_area_id :integer(4)
#  text              :string(255)
#  position          :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  initiative_id     :integer(4)
#  grouping          :string(255)
#

class CopQuestion < ActiveRecord::Base
  validates_presence_of :text, :grouping
  has_many :cop_attributes
  belongs_to :principle_area
  belongs_to :initiative
  
  accepts_nested_attributes_for :cop_attributes, :allow_destroy => true,
                                                 :reject_if     => proc { |a| a['text'].blank? }

  default_scope :order => 'cop_questions.position'
  named_scope :general, :conditions => "initiative_id IS NULL"
  named_scope :initiative_questions_for, lambda { |organization|
    { :conditions => ['initiative_id IN (?)', organization.initiative_ids] }
  }
  named_scope :questions_for, lambda { |organization|
    { :conditions => ['(initiative_id IS NULL) OR (initiative_id IN (?))', organization.initiative_ids] }
  }
  named_scope :group_by, lambda { |group|
    { :conditions => ['grouping =?', group.to_s] }
  }
  
end
