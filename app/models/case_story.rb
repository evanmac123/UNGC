# == Schema Information
#
# Table name: case_stories
#
#  id                         :integer(4)      not null, primary key
#  identifier                 :string(255)
#  organization_id            :integer(4)
#  title                      :string(255)
#  case_date                  :date
#  description                :string(255)
#  url1                       :string(255)
#  url2                       :string(255)
#  url3                       :string(255)
#  author1                    :string(255)
#  author1_institution        :string(255)
#  author1_email              :string(255)
#  author2                    :string(255)
#  author2_institution        :string(255)
#  author2_email              :string(255)
#  reviewer1                  :string(255)
#  reviewer1_institution      :string(255)
#  reviewer1_email            :string(255)
#  reviewer2                  :string(255)
#  reviewer2_institution      :string(255)
#  reviewer2_email            :string(255)
#  uploaded                   :boolean(1)
#  contact1                   :string(255)
#  contact1_email             :string(255)
#  contact2                   :string(255)
#  contact2_email             :string(255)
#  status                     :integer(4)
#  extension                  :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  is_partnership_project     :boolean(1)
#  is_internalization_project :boolean(1)
#  state                      :string(255)
#  attachment_file_name       :string(255)
#  attachment_content_type    :string(255)
#  attachment_file_size       :integer(4)
#  attachment_updated_at      :datetime
#  contact_id                 :integer(4)
#

class CaseStory < ActiveRecord::Base
  include ApprovalWorkflow
  include VisibleTo

  validates_presence_of :organization_id, :title
  belongs_to :organization
  belongs_to :contact
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :principles
  acts_as_commentable
  has_attached_file :attachment

  named_scope :unreplied, :conditions => {:replied_to => false}
end
