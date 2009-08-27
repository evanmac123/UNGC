class LogoRequest < ActiveRecord::Base
  validates_presence_of :organization_id, :requested_on, :publication_id
  belongs_to :organization
  has_many :logo_comments
end
