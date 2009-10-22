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
  named_scope :limit, lambda { |limit| { :limit => limit } }
  named_scope :descending, {:order => 'published_on DESC'}
  named_scope :all_for_year, lambda { |year|
    starts = Time.mktime(year, 1, 1).to_date
    finish = (starts >> 12) - 1
    {
      :conditions => [
        'published_on BETWEEN :starts AND :finish', 
        :starts => starts, :finish => finish
      ]
    }
  }
  
  def self.recent
    published.limit(25).descending
  end
  
  def self.for_year(year)
    published.descending.all_for_year(year)
  end
  
  # Used to make a list of years, for the News Archive page - see pages_helper
  def self.years
    case connection.adapter_name
    when 'MySQL'
      # select distinct(year(published_on)) as year from headlines order by year desc 
      select = 'distinct(year(published_on)) as year'
    when 'SQLite'
      select = "distinct(strftime('%Y', published_on)) as year"
    else
      logger.error " *** Headline.years: Unable to figure out DB: #{connection.adapter_name.inspect}"
    end
    find(:all, :select => select, :order => 'year desc').map { |y| y.year }
  end
  
  def before_approve!
    self.published_on = Date.today
  end

  # 'location' if just location
  # 'country' if just country
  # 'location, country' only if both
  def full_location
    response = []
    response << location if location
    response << country.name if country
    response.join(', ')
  end
end
