# == Schema Information
#
# Table name: logo_comments
#
#  id              :integer(4)      not null, primary key
#  added_on        :date
#  old_id          :integer(4)
#  logo_request_id :integer(4)
#  contact_id      :integer(4)
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#

class LogoComment < ActiveRecord::Base
  validates_presence_of :logo_request_id, :contact_id, :body
  belongs_to :logo_request
  belongs_to :contact
end
