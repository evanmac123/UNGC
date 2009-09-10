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

  attr_accessor :state_event
  after_create :update_request_state
  
  validate :no_comment_on_approved_or_rejected_request
  validate :organization_user_cannot_approve_or_reject
  validate :approved_logos_selected_before_approving_request
  
  private
    def update_request_state
      if contact.from_ungc?
        logo_request.send(state_event) if logo_request.state_events.include?(state_event.to_sym)
      else
        logo_request.reply if logo_request.can_reply?
      end
    end
    
    def no_comment_on_approved_or_rejected_request
      if logo_request && (logo_request.approved? || logo_request.rejected?)
        errors.add_to_base "Cannot add comments to a #{logo_request.state} logo request"
      end
    end
    
    def approved_logos_selected_before_approving_request
      if state_event.to_s == LogoRequest::EVENT_APPROVE && logo_request.logo_files.empty?
        errors.add_to_base "Cannot add comment, unless approved logos have been selected"
      end
    end
    
    def organization_user_cannot_approve_or_reject
      if state_event.to_s == LogoRequest::EVENT_APPROVE || state_event.to_s == LogoRequest::EVENT_REJECT
        errors.add_to_base "Cannot approve/reject comment, unless UNGC staff" unless contact.from_ungc?
      end
    end
end
