# == Schema Information
#
# Table name: events
#
#  id                           :integer          not null, primary key
#  title                        :string(255)
#  description                  :text(65535)
#  starts_at                    :datetime
#  ends_at                      :datetime
#  location                     :text(65535)
#  country_id                   :integer
#  created_by_id                :integer
#  updated_by_id                :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  approved_at                  :datetime
#  approved_by_id               :integer
#  approval                     :string(255)
#  is_all_day                   :boolean
#  is_online                    :boolean
#  is_invitation_only           :boolean
#  priority                     :integer          default(1)
#  contact_id                   :integer
#  thumbnail_image_file_name    :string(255)
#  thumbnail_image_content_type :string(255)
#  thumbnail_image_file_size    :integer
#  thumbnail_image_updated_at   :datetime
#  banner_image_file_name       :string(255)
#  banner_image_content_type    :string(255)
#  banner_image_file_size       :integer
#  banner_image_updated_at      :datetime
#  call_to_action_1_label       :string(255)
#  call_to_action_1_url         :string(255)
#  call_to_action_2_label       :string(255)
#  call_to_action_2_url         :string(255)
#  programme_description        :text(65535)
#  media_description            :text(65535)
#  tab_1_title                  :string(255)
#  tab_1_description            :text(65535)
#  tab_2_title                  :string(255)
#  tab_2_description            :text(65535)
#  tab_3_title                  :string(255)
#  tab_3_description            :text(65535)
#  tab_4_title                  :string(255)
#  tab_4_description            :text(65535)
#  tab_5_title                  :string(255)
#  tab_5_description            :text(65535)
#  sponsors_description         :text(65535)
#

class Event < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  include Indexable
  include Taggable

  belongs_to :country
  belongs_to :contact
  has_attached_file :thumbnail_image, url: "/system/:class/:attachment/:id/:filename"
  has_attached_file :banner_image, url: "/system/:class/:attachment/:id/:filename"

  has_many :event_sponsors, dependent: :destroy
  has_many :sponsors, through: :event_sponsors

  serialize :urls

  validates_presence_of :title, :message => "^Please provide a title"
  validates_presence_of :description, :message => "^Please provide a description"
  validates :thumbnail_image, :attachment_presence => true
  validates_attachment_content_type :thumbnail_image, content_type: [
    'image/png',
    'image/jpeg'
  ]
  validates :banner_image, :attachment_presence => true
  validates_attachment_content_type :banner_image, content_type: [
    'image/png',
    'image/jpeg'
  ]

  validates :call_to_action_1_url, length: { maximum: 255, too_long: "has a %{count} character limit" }
  validates :call_to_action_2_url, length: { maximum: 255, too_long: "has a %{count} character limit" }

  permalink :date_for_permalink

  enum priority: {
    tier1: 1,
    tier2: 2,
    tier3: 3,
  }

  cattr_reader :per_page
  @@per_page = 15


  def self.for_month_year(month=nil, year=nil)
    today = Date.current
    start = Time.mktime( year || today.year, month || today.month, 1).to_date
    finish = (start.to_date >> 1) - 1

    where("starts_at BETWEEN ? AND ?", start, finish)
  end

  def selected_issues
    issues.map {|issue| issue.name }
  end

  def selected_issues=(selected=[])
    new_issues = (selected || []).map { |string| PrincipleArea.find_by_id string.to_i }
    self.issues = new_issues
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

  def ends_at_string
    (ends_at || (Date.current + 1)).strftime('%m/%d/%Y')
  end

  def ends_at_string=(date_or_string)
    if date_or_string.is_a?(String)
      write_attribute(:ends_at, Time.strptime(date_or_string, '%m/%d/%Y').in_time_zone)
    elsif date_or_string.is_a?(Date)
      write_attribute(:ends_at, date_or_string)
    end
  end

  def starts_at_string
    (starts_at || Date.current).strftime('%m/%d/%Y')
  end

  def starts_at_string=(date_or_string)
    if date_or_string.is_a?(String)
      write_attribute(:starts_at, Time.strptime(date_or_string, '%m/%d/%Y').in_time_zone)
    elsif date_or_string.is_a?(Date)
      write_attribute(:starts_at, date_or_string)
    end
  end

  def date_for_permalink
    title.parameterize
  end

  # TODO remove these once we merge redesign
  # they seem to be needed for some html/erb pages
  def starts_on
    starts_at
  end

  def ends_on
    ends_at
  end


end
