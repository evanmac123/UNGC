# == Schema Information
#
# Table name: logo_comments
#
#  id                      :integer          not null, primary key
#  added_on                :date
#  old_id                  :integer
#  logo_request_id         :integer
#  contact_id              :integer
#  body                    :text
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

class LogoComment < ActiveRecord::Base
  validates_presence_of :contact_id
  validates_presence_of :body, :unless => Proc.new { |c| c.state_event == ApprovalWorkflow::EVENT_APPROVE }
  belongs_to :logo_request
  belongs_to :contact

  has_attached_file :attachment,
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"
  do_not_validate_attachment_file_type :attachment

  scope :with_attachment, -> { where("attachment_file_name IS NOT NULL") }
  scope :without_attachment, -> { where("attachment_file_name IS NULL") }

  attr_accessor :state_event
  before_save :add_default_body_to_approval_comment
  after_create :update_request_state
  after_create :update_request_replied_to_and_reviewer_id

  validate :no_comment_on_approved_or_rejected_request
  validate :organization_user_cannot_approve_or_reject
  validate :approved_logos_selected_before_approving_request
  validate :first_comment_needs_a_file

  private
    def update_request_state
      if contact && contact.from_ungc?
        logo_request.send(state_event) if state_event && logo_request.state_events.include?(state_event.to_sym)
      end
    end

    def update_request_replied_to_and_reviewer_id
      logo_request.update_attribute(:replied_to, contact && contact.from_ungc?)
      if contact && contact.from_ungc?
        logo_request.update_attribute(:reviewer_id, contact_id)
      end
    end

    def no_comment_on_approved_or_rejected_request
      if logo_request && (logo_request.approved? || logo_request.rejected?)
        errors.add :base, "cannot add comments to a #{logo_request.state} logo request"
      end
    end

    def approved_logos_selected_before_approving_request
      if state_event.to_s == LogoRequest::EVENT_APPROVE && logo_request.logo_files.empty?
        errors.add :base, "cannot add comment, unless approved logos have been selected"
      end
    end

    def organization_user_cannot_approve_or_reject
      if state_event.to_s == LogoRequest::EVENT_APPROVE || state_event.to_s == LogoRequest::EVENT_REJECT
        errors.add :base, "cannot approve/reject comment, unless UNGC staff" unless contact.from_ungc?
      end
    end

    def first_comment_needs_a_file
      unless logo_request && logo_request.logo_comments.with_attachment.any?
        errors.add :base, "requires a PDF/Word file" unless attachment_file_name
      end
    end

    def add_default_body_to_approval_comment
      if state_event.to_s == LogoRequest::EVENT_APPROVE && body.blank?
        self.body = 'Your logo request has been approved.'
      end
    end
end
