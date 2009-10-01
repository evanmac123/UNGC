# == Schema Information
#
# Table name: comments
#
#  id                      :integer         not null, primary key
#  body                    :text            default("")
#  commentable_id          :integer
#  commentable_type        :string(255)
#  contact_id              :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  default_scope :order => 'created_at ASC'
  belongs_to :contact
  
  has_attached_file :attachment
  named_scope :with_attachment, :conditions => "attachment_file_name IS NOT NULL"
  
  attr_accessor :state_event
  after_create :update_request_state
  
  validate :no_comment_on_approved_or_rejected_commentable
  validate :organization_user_cannot_approve_or_reject

  private
    def update_request_state
      if contact && contact.from_ungc?
        commentable.send(state_event) if state_event && commentable.state_events.include?(state_event.to_sym)
      end
    end
    
    def no_comment_on_approved_or_rejected_commentable
      if commentable && (commentable.approved? || commentable.rejected?)
        errors.add_to_base "cannot add comments to a #{logo_request.state} model"
      end
    end
    
    def organization_user_cannot_approve_or_reject
      if state_event.to_s == LogoRequest::EVENT_APPROVE || state_event.to_s == LogoRequest::EVENT_REJECT
        errors.add_to_base "cannot approve/reject comment, unless UNGC staff" unless contact.from_ungc?
      end
    end
end
