# == Schema Information
#
# Table name: cop_questions
#
#  id                :integer(4)      not null, primary key
#  principle_area_id :integer(4)
#  text              :string(255)
#  area_selected     :boolean(1)
#  position          :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class CopQuestion < ActiveRecord::Base
  validates_presence_of :principle_area_id, :text
  has_many :cop_attributes
  belongs_to :principle_area

  default_scope :order => 'position'
end
