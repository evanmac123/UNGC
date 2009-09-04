# == Schema Information
#
# Table name: logo_approvals
#
#  id              :integer(4)      not null, primary key
#  old_id          :integer(4)
#  logo_request_id :integer(4)
#  logo_file_id    :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

class LogoApproval < ActiveRecord::Base
  validates_presence_of :logo_request_id, :logo_file_id
  belongs_to :logo_request
  belongs_to :logo_file
end
