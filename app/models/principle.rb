# == Schema Information
#
# Table name: principles
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  parent_id  :integer(4)
#

class Principle < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :communication_on_progresses
  acts_as_tree
  
  def self.principles_for_issue_area(area)
    PrincipleArea.area_for(PrincipleArea::FILTERS[area]).children
  end
  
end
