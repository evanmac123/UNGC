# == Schema Information
#
# Table name: logo_comments
#
#  id                      :integer(4)      not null, primary key
#  added_on                :date
#  old_id                  :integer(4)
#  logo_request_id         :integer(4)
#  contact_id              :integer(4)
#  body                    :text
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer(4)
#  attachment_updated_at   :datetime
#

class LogoComment < ActiveRecord::Base
  validates_presence_of :logo_request_id, :contact_id, :body
  belongs_to :logo_request
  belongs_to :contact
  has_attached_file :attachment
  
  named_scope :with_attachment, :conditions => "attachment_file_name IS NOT NULL"

  default_scope :order => 'added_on DESC'
end
