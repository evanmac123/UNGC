# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  old_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  active     :boolean          default(TRUE)
#

class Initiative < ActiveRecord::Base
  has_many :signings
  has_many :signatories, :through => :signings
  has_many :cop_questions
  has_many :roles
  default_scope { order('name') }

  FILTER_TYPES = {
    water_mandate:                 "CEO Water Mandate",
    water_mandate_non_endorsing:   "CEO Water Mandate (Non-Endorsing)",
    climate:                       "Caring For Climate",
    human_rights:                  "CEO Statement on Human Rights",
    lead:                          "Global Compact LEAD",
    business_peace:                "Business for Peace Expert Group",
    business4peace:                "Business for Peace Signatories",
    weps:                          "Women's Empowerment Principles",
    anti_corruption:               "Anti-Corruption Working Group",
    board_members:                 "Board Members",
    gc100:                         "GC 100",
    human_rights_wg:               "Human Rights and Labour Working Group",
    social_enterprise:             "Social Enterprise and Impact Investing Engagement",
    supply_chain:                  "Supply Chain Advisory Group",
  }.with_indifferent_access.freeze

  scope :for_filter, lambda { |filter| where(name: FILTER_TYPES[filter]) }

  scope :active, lambda { where(active: true) }

  def self.id_by_filter(filter)
    for_filter(filter).first&.id
  end

  def self.find_by_filter(filter)
    for_filter(filter).first
  end

end
