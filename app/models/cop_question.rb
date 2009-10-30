class CopQuestion < ActiveRecord::Base
  validates_presence_of :principle_area_id, :text
  has_many :cop_attributes
  belongs_to :principle_area

  default_scope :order => 'position'
end
