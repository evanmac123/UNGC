# == Schema Information
#
# Table name: sectors
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  old_id     :integer(4)
#  icb_number :string(255)
#  parent_id  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Sector < ActiveRecord::Base
  validates_presence_of :name
  acts_as_tree

  default_scope :order => :icb_number
  scope :top_level, where("parent_id IS NULL AND name != 'Not Applicable'")
  scope :participant_search_options, where("parent_id IS NOT NULL AND name != 'Not Applicable'").order('name')

  def self.not_applicable
    find_by_name("Not Applicable")
  end
end
