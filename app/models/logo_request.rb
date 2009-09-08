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
  belongs_to :publication, :class_name => "LogoPublication"
  has_many :logo_comments
  has_and_belongs_to_many :logo_files

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
  
  private
    def set_requested_on
      requested_on = Date.today
    end
end
