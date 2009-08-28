class LogoRequest < ActiveRecord::Base
  validates_presence_of :organization_id, :requested_on, :publication_id
  belongs_to :organization
  belongs_to :contact
  belongs_to :publication, :class_name => "LogoPublication"
  has_many :logo_comments
end
