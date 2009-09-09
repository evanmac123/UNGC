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

  attr_accessor :state_event
  after_save :update_request_state
  
  private
    def update_request_state
      if contact.from_ungc?
        self.logo_request.send(state_event) if logo_request.state_events.include?(state_event)
      else
        self.logo_request.reply if self.logo_request.can_reply?
      end
    end
end
