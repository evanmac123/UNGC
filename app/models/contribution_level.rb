class ContributionLevel < ActiveRecord::Base
  belongs_to :contribution_levels_info
  attr_accessible :amount, :description, :contribution_levels_info_id
  validates :amount, presence: true
  validates :description, presence: true
  validates :contribution_levels_info_id, presence: true
end
