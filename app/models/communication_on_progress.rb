# == Schema Information
#
# Table name: communication_on_progresses
#
#  id                  :integer(4)      not null, primary key
#  identifier          :string(255)
#  organization_id     :integer(4)
#  title               :string(255)
#  related_document    :string(255)
#  email               :string(255)
#  start_year          :integer(4)
#  facilitator         :string(255)
#  job_title           :string(255)
#  start_month         :integer(4)
#  end_month           :integer(4)
#  url1                :string(255)
#  url2                :string(255)
#  url3                :string(255)
#  added_on            :date
#  modified_on         :date
#  contact_name        :string(255)
#  end_year            :integer(4)
#  status              :integer(4)
#  include_ceo_letter  :boolean(1)
#  include_actions     :boolean(1)
#  include_measurement :boolean(1)
#  use_indicators      :boolean(1)
#  cop_score_id        :integer(4)
#  use_gri             :boolean(1)
#  has_certification   :boolean(1)
#  notable_program     :boolean(1)
#  created_at          :datetime
#  updated_at          :datetime
#

class CommunicationOnProgress < ActiveRecord::Base
  include VisibleTo
  include ApprovalWorkflow

  validates_presence_of :organization_id, :title
  belongs_to :organization
  belongs_to :score, :class_name => 'CopScore', :foreign_key => :cop_score_id
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :principles
  acts_as_commentable

  named_scope :for_filter, lambda { |filter_type|
    score_to_find = CopScore.notable if filter_type == :notable
    {
      :include => [:score, {:organization => [:sector, :country]}],
      :conditions => [ "cop_score_id = ?", score_to_find.try(:id) ]
    }
  }
  
  named_scope :by_year, { :order => "end_year DESC, sectors.name ASC, organizations.name ASC" }
  
  def self.find_by_param(param)
    return nil if param.blank?
    if param =~ /\A(\d\d+).*/
      find_by_id param.to_i
    else 
      param = CGI.unescape param
      find :first, :conditions => ["title = ?", param]
    end
  end
  
  def country_name
    organization.try(:country).try(:name)
  end
  
  def ended_on
    time = Time.mktime end_year, end_month, 1
    time.to_date
  end
  
  def organization_name
    organization.try :name || ''    
  end
  
  def sector_name
    organization.sector.try(:name) || ''
  end
  
  def started_on
    time = Time.mktime start_year, start_month, 1
    time.to_date
  end
  
  def urls
    [url1, url2, url3].compact
  end
  
  def year
    end_year
  end
end
