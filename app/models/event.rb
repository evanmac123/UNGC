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
  permalink :title
  
  named_scope :for_month_year, lambda { |month=nil, year=nil|
    today = Date.today
    start = Time.mktime( year || today.year, month || today.month, 1).to_date
    finish = start.to_date >> 1
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
  
  def full_location
    "#{location}, #{country.try(:name)}"
  end
end
