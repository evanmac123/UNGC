class Organization < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :sector
  belongs_to :organization_type
end
