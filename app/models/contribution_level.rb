class ContributionLevel < ActiveRecord::Base
  attr_accessible :amount, :description, :contribution_levels_info_id, :order

  belongs_to :contribution_levels_info

  validates :amount, presence: true
  validates :description, presence: true
  validates :contribution_levels_info_id, presence: true
end
