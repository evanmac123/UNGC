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
    :business_peace => 22, # Expert group
    :business4peace => 51  # Signatories
  }

  scope :for_filter, lambda { |filter| where("initiatives.id = ?", FILTER_TYPES[filter]) }

  def self.contributor_for_years(year)
    if year.is_a?(Array)
     where("initiatives.name IN (?)", year.map {|y| "#{y} Foundation Contributors"})
    else
     where("initiatives.name = ?", "#{year} Foundation Contributors")
    end
  end

  scope :contributor_for_year, lambda { |year| where("initiatives.name = ?", "#{year} Foundation Contributors") }
  scope :for_select, where("initiatives.name NOT LIKE '%Foundation Contributors'")
end
