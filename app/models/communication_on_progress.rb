class CommunicationOnProgress < ActiveRecord::Base
  validates_presence_of :organization_id, :title
  belongs_to :organization
end
