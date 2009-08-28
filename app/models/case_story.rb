class CaseStory < ActiveRecord::Base
  validates_presence_of :organization_id, :title
  belongs_to :organization
  has_and_belongs_to_many :countries
end
