class LogoComment < ActiveRecord::Base
  validates_presence_of :logo_request_id, :contact_id, :body
  belongs_to :logo_request
  belongs_to :contact
end
