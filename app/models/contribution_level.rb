# == Schema Information
#
# Table name: contribution_levels
#
#  id                          :integer          not null, primary key
#  contribution_levels_info_id :integer          not null
#  description                 :string(255)      not null
#  amount                      :string(255)      not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  order                       :integer
#

class ContributionLevel < ActiveRecord::Base
  belongs_to :contribution_levels_info

  validates :amount, presence: true
  validates :description, presence: true
  validates :contribution_levels_info_id, presence: true

  default_scope { order(order: :asc, id: :asc) }
end
