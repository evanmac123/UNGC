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
#  country_id     :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'hpricot'

class Headline < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  permalink :date_for_permalink
  belongs_to :country
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"

  cattr_reader :per_page
  @@per_page = 15
  
  named_scope :published, { :conditions => ['approval = ?', 'approved']}
  named_scope :limit, lambda { |limit| { :limit => limit } }
  named_scope :descending, {:order => 'published_on DESC, approved_at DESC'}
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
    published.descending
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
    self.write_attribute(:published_on, Date.today) if self.published_on.blank?
  end
  
  def published_on_string=(date_or_string)
    if date_or_string.is_a?(String)
      self.write_attribute(:published_on, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      self.write_attribute(:published_on, date_or_string)
    end
  end

  def published_on_string
    (published_on || Date.today).strftime('%m/%d/%Y')
  end

  def formatted_date
    self.published_on.strftime('%e %B, %Y')
  end

  # 'location' if just location
  # 'country' if just country
  # 'location, country' only if both
  def full_location
    response = []
    response << location unless location.blank?
    response << country.name if country
    response.join(', ')
  end
  
  def date_for_permalink
    published_on.strftime('%m-%d-%Y')
  end
  
  # use first paragraph of news item as teaser
  def teaser
   (Hpricot(self.description)/'p').first.inner_html
  end
  
end
