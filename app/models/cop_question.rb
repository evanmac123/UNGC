class CopQuestion < ActiveRecord::Base
  validates_presence_of :principle_area_id, :text
  has_many :cop_attributes
  belongs_to :principle_area
  belongs_to :initiative

  default_scope :order => 'position'
  named_scope :general, :conditions => "initiative_id IS NULL"
  named_scope :initiative_questions_for, lambda { |organization|
    { :conditions => ['initiative_id IN (?)', organization.initiative_ids] }
  }
end
