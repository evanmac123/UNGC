# == Schema Information
#
# Table name: case_stories
#
#  id                    :integer(4)      not null, primary key
#  identifier            :string(255)
#  organization_id       :integer(4)
#  title                 :string(255)
#  case_type             :integer(4)
#  category              :integer(4)
#  case_date             :date
#  description           :string(255)
#  url1                  :string(255)
#  url2                  :string(255)
#  url3                  :string(255)
#  author1               :string(255)
#  author1_institution   :string(255)
#  author1_email         :string(255)
#  author2               :string(255)
#  author2_institution   :string(255)
#  author2_email         :string(255)
#  reviewer1             :string(255)
#  reviewer1_institution :string(255)
#  reviewer1_email       :string(255)
#  reviewer2             :string(255)
#  reviewer2_institution :string(255)
#  reviewer2_email       :string(255)
#  uploaded              :boolean(1)
#  contact1              :string(255)
#  contact1_email        :string(255)
#  contact2              :string(255)
#  contact2_email        :string(255)
#  status                :integer(4)
#  extension             :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class CaseStory < ActiveRecord::Base
  validates_presence_of :organization_id, :title
  belongs_to :organization
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :principles
  acts_as_commentable
  has_attached_file :attachment

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
end
