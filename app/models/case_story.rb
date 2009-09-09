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
end
