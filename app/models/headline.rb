# == Schema Information
#
# Table name: headlines
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  description          :text
#  location             :string(255)
#  published_on         :date
#  created_by_id        :integer
#  updated_by_id        :integer
#  approval             :string(255)
#  approved_at          :datetime
#  approved_by_id       :integer
#  country_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#  headline_type        :integer          default(1)
#  contact_id           :integer
#  call_to_action_label :string(255)
#  call_to_action_url   :string(255)
#

require 'hpricot'

class Headline < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  include Indexable
  include Taggable
  include Permalink

  permalink :date_for_permalink
  belongs_to :country
  belongs_to :contact
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable

  validates_presence_of :title, on: :create, message: "^Please provide a title"
  validates_length_of :title, maximum: 255
  validates :call_to_action_url, length: { maximum: 255, too_long: "has a %{count} character limit" }

  cattr_reader :per_page
  @@per_page = 15

  enum headline_type: {
    press_release: 1,
    announcement: 2,
    executive_update: 3,
  }
  default_scope { order(published_on: :desc, id: :asc) }

  scope :published, -> { where('approval = ?', 'approved') }
  scope :descending, -> { order('published_on DESC, approved_at DESC') }

  def self.all_for_year(year)
    starts = Time.mktime(year, 1, 1).to_date
    finish = (starts >> 12) - 1
    where(published_on: starts..finish)
  end

  def self.recent
    published.descending
  end

  def self.for_year(year)
    published.descending.all_for_year(year)
  end

  # Used to make a list of years, for the News Archive page - see pages_helper
  def self.years
    cast_type = DbConnectionHelper.backend == :mysql ? 'DECIMAL' : 'INTEGER'
    select("distinct(CAST(EXTRACT(YEAR FROM published_on)AS #{cast_type})) as year").reorder('year desc').map {|y| y.year.to_s}
  end

  def before_approve!
    write_attribute(:published_on, Date.current) if self.published_on.blank?
  end

  def published_on_string=(date_or_string)
    if date_or_string.is_a?(String)
      write_attribute(:published_on, Time.strptime(date_or_string, '%m/%d/%Y').in_time_zone)
    elsif date_or_string.is_a?(Date)
      write_attribute(:published_on, date_or_string)
    end
  end

  def published_on_string
    (published_on || Date.current).strftime('%m/%d/%Y')
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
    published_on.try(:strftime, '%m-%d-%Y') # TODO determine if published_on should simply be required
  end

  # use first paragraph of news item as teaser
  def teaser
    (Hpricot(self.description)/'p').first.inner_html
  rescue
    ''
  end

  def missing_call_to_action?
    call_to_action_label.blank?
  end

end
