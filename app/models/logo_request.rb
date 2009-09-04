class LogoRequest < ActiveRecord::Base
  validates_presence_of :organization_id, :requested_on, :publication_id
  belongs_to :organization
  belongs_to :contact
  belongs_to :publication, :class_name => "LogoPublication"
  has_many :logo_comments

  state_machine :state, :initial => :incomplete do
    event :submit do
      transition :from => :incomplete, :to => :pending
    end
    event :approve do
      transition :from => :pending, :to => :approved
    end
    event :reject do
      transition :from => :pending, :to => :rejected
    end
  end

  named_scope :incomplete, :conditions => {:state => "incomplete"}
  named_scope :pending, :conditions => {:state => "pending"}
  named_scope :approved, :conditions => {:state => "approved"}
  named_scope :rejected, :conditions => {:state => "rejected"}
end