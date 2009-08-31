class Organization < ActiveRecord::Base
  validates_presence_of :name
  has_many :contacts
  belongs_to :sector
  belongs_to :organization_type
  belongs_to :country

  accepts_nested_attributes_for :contacts
end
