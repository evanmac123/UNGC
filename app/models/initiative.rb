# == Schema Information
#
# Table name: initiatives
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  old_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Initiative < ActiveRecord::Base
  has_many :signings
  has_many :signatories, :through => :signings
  has_many :cop_questions
  has_many :roles
  default_scope :order => 'name'

  FILTER_TYPES = {
    :water_mandate  => 1,
    :climate        => 2,
    :human_rights   => 4,
    :lead           => 19,
    :business_peace => 22
  }

  scope :for_filter, lambda { |filter| where("initiatives.id = ?", FILTER_TYPES[filter]) }
end
