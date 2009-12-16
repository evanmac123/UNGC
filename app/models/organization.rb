# == Schema Information
#
# Table name: organizations
#
#  id                             :integer(4)      not null, primary key
#  old_id                         :integer(4)
#  name                           :string(255)
#  organization_type_id           :integer(4)
#  sector_id                      :integer(4)
#  local_network                  :boolean(1)
#  participant                    :boolean(1)
#  employees                      :integer(4)
#  url                            :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#  added_on                       :date
#  modified_on                    :date
#  joined_on                      :date
#  delisted_on                    :date
#  active                         :boolean(1)
#  country_id                     :integer(4)
#  stock_symbol                   :string(255)
#  removal_reason_id              :integer(4)
#  last_modified_by_id            :integer(4)
#  state                          :string(255)
#  exchange_id                    :integer(4)
#  listing_status_id              :integer(4)
#  is_ft_500                      :boolean(1)
#  cop_status                     :integer(4)
#  cop_due_on                     :date
#  inactive_on                    :date
#  one_year_member_on             :string(255)
#  commitment_letter_file_name    :string(255)
#  commitment_letter_content_type :string(255)
#  commitment_letter_file_size    :integer(4)
#  commitment_letter_updated_at   :datetime
#  pledge_amount                  :integer(4)
#  old_tmp_id                     :integer(4)
#  cop_state                      :string(255)
#  replied_to                     :boolean(1)
#  reviewer_id                    :integer(4)
#

class Organization < ActiveRecord::Base
  include ApprovalWorkflow

  validates_presence_of :name
  has_many :signings
  has_many :initiatives, :through => :signings
  has_many :contacts 
  has_many :logo_requests
  has_many :case_stories, :order => 'case_stories.updated_at ASC'
  has_many :communication_on_progresses
  belongs_to :sector
  belongs_to :organization_type
  belongs_to :listing_status
  belongs_to :exchange
  belongs_to :country
  belongs_to :removal_reason

  attr_accessor :pledge_amount_other
  
  validate :pledge_amount_other_at_least_10000
  
  accepts_nested_attributes_for :contacts
  acts_as_commentable
  
  before_save :check_micro_enterprise_or_sme
  before_save :check_pledge_amount_other
  before_save :set_non_business_sector
  
  has_attached_file :commitment_letter

  define_index do
    indexes name
    has country(:id), :as => :country_id, :facet => true
    has country(:name), :as => :country_name, :facet => true
    has organization_type(:type_property), :as => :business, :facet => true
    has organization_type(:id), :as => :organization_type_id, :facet => true
    has cop_state, :facet => true
    has joined_on, :facet => true
    has delisted_on, :facet => true
    where 'organizations.state = "approved"' #FIXME: Exclude everything except participants, possibly exclude delisted?
    # set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
  end
  
  COP_STATE_ACTIVE = 'active'
  COP_STATE_NONCOMMUNICATING = 'noncommunicating'
  COP_STATE_DELISTED = 'delisted'
  
  COP_STATES = {
    :active => COP_STATE_ACTIVE,
    :noncommunicating => COP_STATE_NONCOMMUNICATING,
    :delisted => COP_STATE_DELISTED
  }
  
  state_machine :cop_state, :initial => :active do
    event :communication_late do
      transition :from => :active, :to => :noncommunicating
    end
    event :delist do
      transition :from => :noncommunicating, :to => :delisted
    end
    event :communication_received do
      transition :from => :noncommunicating, :to => :active
    end
  end
  
  named_scope :local_network, :conditions => ["local_network = ?", true]

  named_scope :active,
    { :conditions => ["organizations.active = ?", true] }

  named_scope :participants,
    { :conditions => ["organizations.participant = ?", true] }

  named_scope :companies_and_smes, { 
    :include => :organization_type,
    :conditions => ["organization_type_id IN (?)", OrganizationType.for_filter(:sme, :companies) ] 
  }

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
  
  named_scope :last_joined, {
    :order => "joined_on DESC, name DESC"
  }
  
  named_scope :with_cop_status, lambda { |filter_type|
    if filter_type.is_a?(Array)
      statuses = filter_type.map { |t| COP_STATES[t] }
      {:conditions => ["cop_state IN (?)", statuses]}
    else
      {:conditions => ["cop_state = ?", COP_STATES[filter_type]]}
    end
  }
  
  named_scope :with_cop_due_on, lambda { |date|
    {:conditions => {:cop_due_on => date} }
  }

  named_scope :visible_to, lambda { |user|
    if user.user_type == Contact::TYPE_ORGANIZATION
      { :conditions => ['id=?', user.organization_id] }
    elsif user.user_type == Contact::TYPE_NETWORK
      { :conditions => ["country_id in (?)", user.local_network.country_ids] }
    else
      {}
    end
  }
    
  named_scope :listed,
    { :conditions => "organizations.stock_symbol IS NOT NULL" }
  
  named_scope :without_contacts,
    { :conditions => "not exists(select * from contacts c where c.organization_id = organizations.id)" }
  
  named_scope :where_country_id, lambda {|id_or_array| 
    if id_or_array.is_a?(Array)
      { :conditions => ['country_id IN (?)', id_or_array] }
    else
      { :conditions => {:country_id => id} }
    end
  }
  
  named_scope :created_in, lambda { |month, year|
    { :conditions => ['created_at >= ? AND created_at <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month] }
  }
  
  named_scope :with_pledge, :conditions => 'pledge_amount > 0'
  
  named_scope :about_to_become_noncommunicating, lambda {
    { conditions: ["cop_state=? AND cop_due_on<=?", COP_STATE_ACTIVE, 1.day.ago.to_date] }
  }

  named_scope :about_to_become_delisted, lambda {
    { conditions: ["cop_state=? AND cop_due_on<=?", COP_STATE_NONCOMMUNICATING, (1.year + 1.day).ago.to_date] }
  }

  def network_report_recipients
    Contact.network_report_recipients.for_country(self.country)
  end
  
  def self.find_by_param(param)
    return nil if param.blank?
    param = CGI.unescape param
    find :first, :conditions => ["name = ?", param]
  end
  
  def self.visible_in_local_network
    statuses = [:noncommunicating, :active, :delisted]
    participants.active.with_cop_status(statuses)
  end

  def country_name
    country.name
  end

  def company?
    organization_type.try(:name) == 'Company'
  end

  def public_company?
    listing_status.try(:name) == 'Public Company'
  end

  def micro_enterprise?
    organization_type_id == OrganizationType.micro_enterprise.try(:id)
  end
  
  def country_name
    country.try(:name)
  end
  
  def sector_name
    sector.try(:name)
  end
  
  def business_for_search
    business_entity? ? 1 : 0
  end
  
  def business_entity?
    organization_type.business?
  end
  
  # NOTE: Convenient alias
  def noncommed_on; cop_due_on; end

  def invoice_id
    "FGCD#{id}"
  end
  
  # TODO: save date when invoice is sent
  def days_since_invoiced
    22
  end
  
  def to_param
    CGI.escape(name)    
  end
  
  def noncommunicating?
    cop_state == COP_STATE_NONCOMMUNICATING
  end
  
  # Indicates if this organization uses the most recent COP rules
  def july_1_2009_cop_rules?
    self.joined_on > Date.new(2009,7,1)
  end
  
  # COP's next due date is 1 year from current date
  def set_next_cop_due_date
    self.communication_received
    self.update_attribute :cop_due_on, 1.year.from_now
  end
  
  private
  
   def set_non_business_sector
     unless self.business_entity?
       self.sector = Sector.not_applicable
     end
   end
  
    def check_pledge_amount_other
      unless self.pledge_amount_other.to_i == 0
        self.pledge_amount = self.pledge_amount_other
      end
    end
  
    def check_micro_enterprise_or_sme
      # we don't make assumptions if there is no employees information
      return if self.employees.nil?
      if self.business_entity?
        if self.employees < 10
          self.organization_type_id = OrganizationType.micro_enterprise.id
        elsif self.employees < 250
          self.organization_type_id = OrganizationType.sme.id
        end
      end
    end
    
    def pledge_amount_other_at_least_10000
      if pledge_amount_other.to_i != 0 and pledge_amount_other.to_i < 10000
        errors.add :pledge_amount_other, "cannot be less than US$10,000"
      end
    end
end
