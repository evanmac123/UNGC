class Event < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  include Indexable

  belongs_to :country
  has_attached_file :thumbnail_image, url: "/system/:class/:attachment/:id/:filename"
  has_attached_file :banner_image, url: "/system/:class/:attachment/:id/:filename"

  has_many :taggings
  has_many :sectors,        through: :taggings
  has_many :sector_groups,  through: :sectors, class_name: 'Sector', source: :parent
  has_many :issues,         through: :taggings
  has_many :issue_areas,    through: :issues, class_name: 'Issue', source: :parent
  has_many :topics,         through: :taggings
  has_many :topic_groups,   through: :topics, class_name: 'Topic', source: :parent

  serialize :urls
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"
  do_not_validate_attachment_file_type :thumbnail_image
  do_not_validate_attachment_file_type :banner_image
  permalink :date_for_permalink

  enum priority: {
    tier1: 1,
    tier2: 2,
    tier3: 3,
  }

  cattr_reader :per_page
  @@per_page = 15

  def self.for_month_year(month=nil, year=nil)
    today = Date.today
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
    (ends_at || (Date.today + 1)).strftime('%m/%d/%Y')
  end

  def ends_at_string=(date_or_string)
    if date_or_string.is_a?(String)
      write_attribute(:ends_at, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      write_attribute(:ends_at, date_or_string)
    end
  end

  def starts_at_string
    (starts_at || Date.today).strftime('%m/%d/%Y')
  end

  def starts_at_string=(date_or_string)
    if date_or_string.is_a?(String)
      write_attribute(:starts_at, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      write_attribute(:starts_at, date_or_string)
    end
  end

  def date_for_permalink
    (starts_at || Date.today).strftime('%m-%d-%Y')
  end
end
