# == Schema Information
#
# Table name: events
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  description    :text
#  starts_on      :date
#  ends_on        :date
#  location       :text
#  country_id     :integer(4)
#  urls           :text
#  created_by_id  :integer(4)
#  updated_by_id  :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#  approved_at    :datetime
#  approved_by_id :integer(4)
#  approval       :string(255)
#

class Event < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  belongs_to :country
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable
  has_and_belongs_to_many :issues, :class_name => 'PrincipleArea', :join_table => :events_principles
  serialize :urls
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"
  permalink :date_for_permalink

  cattr_reader :per_page
  @@per_page = 15

  named_scope :for_month_year, lambda { |month=nil, year=nil|
    today = Date.today
    start = Time.mktime( year || today.year, month || today.month, 1).to_date
    finish = (start.to_date >> 1) - 1
    {
      :conditions => [
        "starts_on BETWEEN :start AND :finish",
        {
          :start  => start,
          :finish => finish
        }
      ]
    }
  }

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

  def ends_on_string
    (ends_on || (Date.today + 1)).strftime('%m/%d/%Y')
  end

  def ends_on_string=(date_or_string)
    if date_or_string.is_a?(String)
      self.write_attribute(:ends_on, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      self.write_attribute(:ends_on, date_or_string)
    end
  end

  def starts_on_string
    (starts_on || Date.today).strftime('%m/%d/%Y')
  end

  def starts_on_string=(date_or_string)
    if date_or_string.is_a?(String)
      self.write_attribute(:starts_on, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      self.write_attribute(:starts_on, date_or_string)
    end
  end

  def date_for_permalink
    (starts_on || Date.today).strftime('%m-%d-%Y')
  end
end
