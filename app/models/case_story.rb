# == Schema Information
#
# Table name: case_stories
#
#  id                         :integer(4)      not null, primary key
#  identifier                 :string(255)
#  organization_id            :integer(4)
#  title                      :string(255)
#  case_date                  :date
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
#  description                :text
#  replied_to                 :boolean(1)
#  reviewer_id                :integer(4)
#

class CaseStory < ActiveRecord::Base
  include ApprovalWorkflow
  include VisibleTo

  validates_presence_of :organization_id, :title
  belongs_to :organization
  belongs_to :contact
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :principles
  
  delegate :name, :to => :organization, :prefix => true
  acts_as_commentable
  has_attached_file :attachment
  
  cattr_reader :per_page
  @@per_page = 15

  named_scope :unreplied, :conditions => {:replied_to => false}
  
  def authors_for_display
    authors = [
      [author1, author1_email, author1_institution],
      [author2, author2_email, author2_institution]
    ]
    
    authors.map do |details|
      display_contact(*details) unless author1.blank?
    end
  end
  
  def category_name
    if is_partnership_project? and is_internalization_project?
      'Internalization and Partnership Project'
    elsif is_partnership_project?
      'Partnership Project'
    elsif is_internalization_project?
      'Internalization Project'
    else
      'Unknown'
    end
  end
  
  def contact_for_display
    display_contact(contact.name, contact.email, contact.organization_name) if contact
  end

  def country_names
    countries.map { |c| c.try :name }.sort.join(', ')
  end
  
  def display_contact(name, email, institution)
    OpenStruct.new(name: name, email: email, institution: institution)
  end
  
  def links
    links = [url1, url2, url3].compact
    links << attachment if attachment
    links
  end
  
  def set_approved_fields
  end
end
