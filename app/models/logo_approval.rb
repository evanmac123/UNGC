class LogoApproval < ActiveRecord::Base
  validates_presence_of :logo_request_id, :logo_file_id
  belongs_to :logo_request
  belongs_to :logo_file
end
