# == Schema Information
#
# Table name: sectors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  old_id     :integer
#  icb_number :string(255)
#  parent_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Sector < ActiveRecord::Base
  validates_presence_of :name
  acts_as_tree

  default_scope { order(:icb_number) }
  scope :applicable, -> { where("sectors.name != ?", 'Not Applicable') }
  scope :top_level, -> { applicable.where(parent_id:nil) }
  scope :participant_search_options, -> { applicable.where.not(parent_id:nil).order('name') }

  def self.not_applicable
    find_by_name("Not Applicable")
  end

  def self.children
    self.participant_search_options
  end
end
