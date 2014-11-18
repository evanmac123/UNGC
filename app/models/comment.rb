	# == Schema Information
#
# Table name: comments
#
#  id                      :integer          not null, primary key
#  body                    :text
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
  validates_presence_of :body, :unless => Proc.new { |c| ApprovalWorkflow::STAFF_EVENTS.include?(c.state_event) }
  belongs_to :commentable, :polymorphic => true
  belongs_to :contact

  has_attached_file :attachment,
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"

  default_scope { order('updated_at DESC') }
  scope :with_attachment, lambda { where("attachment_file_name IS NOT NULL") }

  # copy email to local network if option is selected
  attr_accessor :copy_local_network

  attr_accessor :state_event
  before_save :add_default_body_to_comment
  after_create :update_commentable_state
  after_create :update_commentable_replied_to_and_reviewer_id

  validate :no_comment_on_approved_or_rejected_commentable
  validate :organization_user_cannot_approve_or_reject

  def copy_local_network?
   copy_local_network.to_i == 1 ? true : false
  end

  def contact_name
    contact.try(:name) || "Contact #{contact_id}"
  end

  private
    def update_commentable_state
      if contact && contact.from_ungc?
        commentable.send(state_event) if state_event && commentable.state_events.include?(state_event.to_sym)
      end
    end

    def no_comment_on_approved_or_rejected_commentable
      if commentable && (commentable.approved? || commentable.rejected?)
        errors.add :base, "cannot add comments to a #{commentable.state} model"
      end
    end

    def organization_user_cannot_approve_or_reject
      if ApprovalWorkflow::STAFF_EVENTS.include? state_event.to_s
        errors.add :base, "cannot approve/reject comment, unless you are Global Compact staff" unless contact.from_ungc?
      end
    end

    def update_commentable_replied_to_and_reviewer_id
      commentable.update_attribute(:replied_to, contact && contact.from_ungc?)
      if contact && contact.from_ungc?
        commentable.update_attribute(:reviewer_id, contact_id)
      end
    end

    def add_default_body_to_comment
      if state_event.to_s == ApprovalWorkflow::EVENT_NETWORK_REVIEW && body.blank?
        self.body = 'Your application is under review by the Local Network in your country.'
      end
      if state_event.to_s == ApprovalWorkflow::EVENT_DELAY_REVIEW && body.blank?
        self.body = 'Your application is under review by the Global Compact Office.'
      end
      if state_event.to_s == ApprovalWorkflow::EVENT_APPROVE && body.blank?
        self.body = 'Your application has been accepted.'
      end
      if state_event.to_s == ApprovalWorkflow::EVENT_REJECT && body.blank?
        self.body = 'Your application could not be accepted.'
      end
      if state_event.to_s == ApprovalWorkflow::EVENT_REJECT_MICRO && body.blank?
        self.body = 'Your application could not be accepted.'
      end
    end
end
