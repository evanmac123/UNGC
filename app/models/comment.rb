# == Schema Information
#
# Table name: comments
#
#  id                      :integer(4)      not null, primary key
#  body                    :text
#  commentable_id          :integer(4)
#  commentable_type        :string(255)
#  contact_id              :integer(4)
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer(4)
#  attachment_updated_at   :datetime
#

class Comment < ActiveRecord::Base
  validates_presence_of :body
  belongs_to :commentable, :polymorphic => true
  default_scope :order => 'created_at ASC'
  belongs_to :contact
  
  has_attached_file :attachment
  named_scope :with_attachment, :conditions => "attachment_file_name IS NOT NULL"
  
  attr_accessor :state_event
  after_create :update_commentable_state
  after_create :update_commentable_replied_to_and_reviewer_id
  
  validate :no_comment_on_approved_or_rejected_commentable
  validate :organization_user_cannot_approve_or_reject

  private
    def update_commentable_state
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
    
    def update_commentable_replied_to_and_reviewer_id
      commentable.update_attribute(:replied_to, contact && contact.from_ungc?)
      if contact && contact.from_ungc?
        commentable.update_attribute(:reviewer_id, contact_id)
      end
    end
    
end
