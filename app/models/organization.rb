# == Schema Information
#
# Table name: organizations
#
#  id                   :integer(4)      not null, primary key
#  old_id               :integer(4)
#  name                 :string(255)
#  organization_type_id :integer(4)
#  sector_id            :integer(4)
#  local_network        :boolean(1)
#  participant          :boolean(1)
#  employees            :integer(4)
#  url                  :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  added_on             :date
#  modified_on          :date
#  joined_on            :date
#  delisted_on          :date
#  active               :boolean(1)
#  country_id           :integer(4)
#  stock_symbol         :string(255)
#  removal_reason_id    :integer(4)
#  last_modified_by_id  :integer(4)
#  state                :string(255)
#  exchange_id          :integer(4)
#  listing_status_id    :integer(4)
#  is_ft_500            :boolean(1)
#

class Organization < ActiveRecord::Base
  validates_presence_of :name
  has_many :signings
  has_many :initiatives, :through => :signings
  has_many :contacts
  has_many :logo_requests
  has_many :case_stories
  has_many :communication_on_progresses
  belongs_to :sector
  belongs_to :organization_type
  belongs_to :listing_status
  belongs_to :exchange
  belongs_to :country

  before_save :automatic_submit

  accepts_nested_attributes_for :contacts
  
  acts_as_commentable
  
  state_machine :state, :initial => :incomplete do
    event :submit do
      transition :from => :incomplete, :to => :pending
    end
    event :approve do
      transition :from => :pending, :to => :approved
    end
    event :reject do
      transition :from => :pending, :to => :rejected
    end
  end
  
  COP_STATUSES = {
    :inactive         => 0,
    :noncommunicating => 1,
    :active           => 2,
    :delisted         => 3
  }

  named_scope :incomplete, :conditions => {:state => "incomplete"}
  named_scope :pending, :conditions => {:state => "pending"}
  named_scope :approved, :conditions => {:state => "approved"}
  named_scope :rejected, :conditions => {:state => "rejected"}

  named_scope :participants,
    { :conditions => ["organizations.participant = ?", true] }

  named_scope :by_type, lambda { |filter_type|
    {
      :include => :organization_type,
      :conditions => ["organization_type_id IN (?)", OrganizationType.for_filter(filter_type).map(&:id)]
    }
  }
  
  named_scope :for_initiative, lambda { |symbol|
    {
      :include => :initiatives,
      :conditions => ["initiatives.id IN (?)", Initiative.for_filter(symbol).map(&:id) ],
      :order => "organizations.name ASC"
    }
  }
  
  named_scope :with_cop_status, lambda { |filter_type|
    {
      :conditions => ["cop_status = ?", COP_STATUSES[filter_type]]
    }
  }

  named_scope :visible_to, lambda { |user|
    if user.user_type == Contact::TYPE_ORGANIZATION
      { :conditions => ['id=?', user.organization_id] }
    else
      # TODO implement for network
      {}
    end
  }

  def country_name
    country.name
  end

  def company?
    organization_type.try(:name) == 'Company'
  end

  def public_company?
    listing_status.try(:name) == 'Public Company'
  end
  
  def country_name
    country.try(:name)
  end
  
  def sector_name
    sector.try(:name)
  end
  
  # NOTE: Convenient alias
  def noncommed_on; cop_due_on; end
  
  private
    def automatic_submit
      if state == "incomplete"
        # we want the organization to be in the submitted state when some
        # minimum amount of data is entered
        # TODO when do we move an organization to submitted state?
        self.submit if contacts.any?
      end
    end
end
