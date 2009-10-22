# == Schema Information
#
# Table name: headlines
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  description    :text
#  location       :string(255)
#  published_on   :date
#  created_by_id  :integer(4)
#  updated_by_id  :integer(4)
#  approval       :string(255)
#  approved_at    :datetime
#  approved_by_id :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Headline < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  permalink :title
  belongs_to :country
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"

  named_scope :published, { :conditions => ['approval = ?', 'approved']}
  
  def self.recent
    published.find :all,
      :limit => 25,
      :order => 'published_on DESC'
  end
  
  def self.for_year(year)
    starts = Time.mktime(year, 1, 1).to_date
    finish = (starts >> 12) - 1
    published.find :all,
      :conditions => ['published_on BETWEEN :starts AND :finish', :starts => starts, :finish => finish],
      :order => 'published_on DESC'
  end
  
  def self.years
    # select distinct(year(published_on)) as year from headlines order by year desc 
    find(:all, :select => 'distinct(year(published_on)) as year', :order => 'year desc')
  end
  
  def before_approve!
    self.published_on = Date.today
  end

  def full_location
    "#{location}, #{country.try(:name)}"
  end
end
