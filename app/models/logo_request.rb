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
#  approved_on       :date
#

class LogoRequest < ActiveRecord::Base
  include VisibleTo

  validates_presence_of :organization_id, :publication_id, :purpose
  belongs_to :organization
  belongs_to :contact
  belongs_to :reviewer, :class_name => "Contact"
  belongs_to :publication, :class_name => "LogoPublication"
  has_many :logo_comments, :dependent => :delete_all, :order => 'logo_comments.created_at DESC'
  has_and_belongs_to_many :logo_files

  accepts_nested_attributes_for :logo_comments
  
  attr_reader :per_page
  @@per_page = 15

  state_machine :state, :initial => :pending_review do
    after_transition :on => :approve, :do => :set_approved_on
    after_transition :on => :accept, :do => :set_accepted_on
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

  named_scope :in_review, :conditions => {:state => "in_review"},
                          :joins => :logo_comments,
                          :group => :logo_request_id,
                          :order => 'logo_comments.created_at DESC' 
  
  named_scope :approved, :conditions => {:state => "approved"}
  named_scope :rejected, :conditions => {:state => "rejected"}
  named_scope :accepted, :conditions => {:state => "accepted"}
  named_scope :approved_or_accepted, :conditions => "state in ('approved','accepted')"

  named_scope :unreplied, :conditions => {:replied_to => false, :state => "in_review"},
                          :joins => :logo_comments,
                          :group => :logo_request_id,
                          :order => 'logo_comments.created_at DESC' 

  named_scope :approved_between, lambda { |month, year|
    {
      :conditions => ["state in ('approved', 'accepted') AND approved_on >= ? AND approved_on <= ?",
                      Date.new(year, month, 1), Date.new(year, month, 1).end_of_month],
      :order => "approved_on DESC"
    }
  }
  
  
  STATE_PENDING_REVIEW = 'pending_review'
  STATE_IN_REVIEW = 'in_review'
  STATE_APPROVED = 'approved'
  STATE_REJECTED = 'rejected'
  STATE_ACCEPTED = 'accepted'
  
  EVENT_REVISE = 'revise'
  EVENT_REPLY = 'reply'
  EVENT_REJECT = 'reject'
  EVENT_APPROVE = 'approve'
  EVENT_ACCEPT = 'accept'
  
  def can_download_files?
    accepted? && Time.now <= accepted_on + 7.days
  end
  
  def days_to_process
    (self.approved_on.to_date - self.created_at.to_date).to_i
  end
  
  private
    def set_approved_on
      update_attribute :approved_on, Date.today
    end
    
    def set_accepted_on
      update_attribute :accepted_on, Date.today
    end
end
