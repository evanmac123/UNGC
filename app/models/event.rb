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
#  approved       :boolean(1)
#  approved_at    :datetime
#  approved_by_id :integer(4)
#

class Event < ActiveRecord::Base
  belongs_to :country
  belongs_to :created_by, :class_name => 'Contact', :foreign_key => :created_by_id
  belongs_to :updated_by, :class_name => 'Contact', :foreign_key => :updated_by_id
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable
  has_and_belongs_to_many :issues, :class_name => 'PrincipleArea', :join_table => :events_principles
  serialize :urls
  validates_presence_of :title, :on => :create, :message => "^Please provide a title"
  

  named_scope :for_month_year, lambda { |month=nil, year=nil|
    today = Date.today
    logger.info " ** Looking for #{year || today.year}, #{month || today.month}"
    start = Time.mktime( year || today.year, month || today.month, 1)
    finish = (start.to_date >> 1).to_time
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
  
  
  def self.find_by_permalink(permalink)
    find_by_id permalink.to_i
  end
  
  def to_param
    if !title.blank?
      escaped = CGI.escape(title.downcase)
      permalink = escaped.gsub(/(\%..|\+)/, '-')
      permalink.gsub!(/-+/, '-')
      permalink.gsub!(/-\Z/, '')
      "#{id}-#{permalink}"
    else
      id.to_s
    end
  end
  
  def full_location
    "#{location}, #{country.try(:name)}"
  end

  # FIXME: Make this a module?
  attr_writer :current_user
  before_create :set_created_by
  before_update :set_updated_by
  
  def set_created_by
    self.created_by ||= @current_user if @current_user
  end
  
  def set_updated_by
    self.updated_by ||= @current_user if @current_user
  end

end
