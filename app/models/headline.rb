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

  scope :published, where('approval = ?', 'approved')
  scope :descending, order('published_on DESC, approved_at DESC')

  def self.all_for_year(year)
    starts = Time.mktime(year, 1, 1).to_date
    finish = (starts >> 12) - 1
    where('published_on BETWEEN ? AND ?', starts, finish)
  end

  def self.recent
    published.descending
  end

  def self.for_year(year)
    published.descending.all_for_year(year)
  end

  # Used to make a list of years, for the News Archive page - see pages_helper
  def self.years
    select("distinct(year(published_on)) as year").order('year desc').map {|y| y.year.to_s}
  end

  def before_approve!
    write_attribute(:published_on, Date.today) if self.published_on.blank?
  end

  def published_on_string=(date_or_string)
    if date_or_string.is_a?(String)
      write_attribute(:published_on, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      write_attribute(:published_on, date_or_string)
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
