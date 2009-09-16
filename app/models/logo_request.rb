# == Schema Information
#
# Table name: logo_requests
#
#  id                :integer(4)      not null, primary key
#  old_id            :integer(4)
#  requested_on      :date
#  status_changed_on :date
#  publication_id    :integer(4)
#  organization_id   :integer(4)
#  contact_id        :integer(4)
#  reviewer_id       :integer(4)
#  replied_to        :boolean(1)
#  purpose           :string(255)
#  status            :string(255)
#  accepted          :boolean(1)
#  accepted_on       :date
#  created_at        :datetime
#  updated_at        :datetime
#  state             :string(255)
#

class LogoRequest < ActiveRecord::Base
  validates_presence_of :organization_id, :publication_id
  belongs_to :organization
  belongs_to :contact
  belongs_to :reviewer, :class_name => "Contact"
  belongs_to :publication, :class_name => "LogoPublication"
  has_many :logo_comments
  has_and_belongs_to_many :logo_files

  accepts_nested_attributes_for :logo_comments

  state_machine :state, :initial => :pending_review do
    event :revise do
      transition :from => :pending_review, :to => :in_review
    end
    event :approve do
      transition :from => [:in_review, :pending_review], :to => :approved
    end
    event :reject do
      transition :from => [:in_review, :pending_review], :to => :rejected
    end
    event :accept do
      transition :from => :approved, :to => :accepted
    end
  end

  named_scope :pending_review, :conditions => {:state => "pending_review"}
  named_scope :in_review, :conditions => {:state => "in_review"}
  named_scope :approved, :conditions => {:state => "approved"}
  named_scope :rejected, :conditions => {:state => "rejected"}
  named_scope :accepted, :conditions => {:state => "accepted"}

  named_scope :unreplied, :conditions => {:replied_to => false}

  named_scope :visible_to, lambda { |user|
    if user.user_type == Contact::TYPE_ORGANIZATION
      { :conditions => ['organization_id=?', user.organization_id] }
    else
      # TODO implement for network
      {}
    end
  }
  
  EVENT_REVISE = 'revise'
  EVENT_REPLY = 'reply'
  EVENT_REJECT = 'reject'
  EVENT_APPROVE = 'approve'
  
  private
    def set_requested_on
      requested_on = Date.today
    end
end
