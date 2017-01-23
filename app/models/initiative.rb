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
    :water_mandate  => 1,  # CEO Water Mandate
    :climate        => 2,  # Caring For Climate
    :human_rights   => 4,  # CEO Statement on Human Rights
    :lead           => 19, # Global Compact Lead
    :business_peace => 22, # Business for Peace - Expert group
    :business4peace => 51, # Business for Peace - Signatories
    :weps           => 25  # Women's Empowerment Principles
  }.with_indifferent_access.freeze

  scope :for_filter, lambda { |filter| where("initiatives.id = ?", FILTER_TYPES[filter]) }

  scope :active, lambda { where(active: true) }

  def self.id_by_filter(filter)
    FILTER_TYPES[filter]
  end

  def self.find_by_filter(filter)
    find(id_by_filter(filter))
  end

end
