# == Schema Information
#
# Table name: organizations
#
#  id                             :integer(4)      not null, primary key
#  old_id                         :integer(4)
#  name                           :string(255)
#  organization_type_id           :integer(4)
#  sector_id                      :integer(4)
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
#  cop_due_on                     :date
#  inactive_on                    :date
#  commitment_letter_file_name    :string(255)
#  commitment_letter_content_type :string(255)
#  commitment_letter_file_size    :integer(4)
#  commitment_letter_updated_at   :datetime
#  pledge_amount                  :integer(4)
#  old_tmp_id                     :integer(4)
#  cop_state                      :string(255)
#  replied_to                     :boolean(1)
#  reviewer_id                    :integer(4)
#  bhr_url                        :string(255)
#  rejected_on                    :date
#  network_review_on              :date
#  local_network                  :boolean(1)
#  revenue                        :integer(4)
#

class Organization < ActiveRecord::Base
  include ApprovalWorkflow

  validates_presence_of :name
  validates_uniqueness_of :name, :on => :update, :message => "has already been used by another organization" 
  validates_numericality_of :employees, :only_integer => true, :message => "should only contain numbers. No commas or periods are required."
  validates_format_of :url,
                       :with => (/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix),
                       :message => "for website is invalid. Please enter one address in the format http://unglobalcompact.org/",
                       :unless => Proc.new { |organization| organization.url.blank? }
  validates_presence_of :stock_symbol, :if => Proc.new { |organization| organization.public_company? }
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

  attr_accessor :delisting_on
  
  accepts_nested_attributes_for :contacts
  acts_as_commentable
  
  before_save :check_micro_enterprise_or_sme
  before_save :set_non_business_sector
  
  has_attached_file :commitment_letter
  
  cattr_reader :per_page
  @@per_page = 100

  define_index do
    indexes name, :sortable => true
    has country(:id), :as => :country_id, :facet => true
    has country(:name), :as => :country_name, :facet => true
    has organization_type(:type_property), :as => :business, :facet => true
    has organization_type(:id), :as => :organization_type_id, :facet => true
    has sector(:id), :as => :sector_id, :facet => true
    has sector(:name), :as => :sector_name, :facet => true
    has listing_status(:id), :as => :listing_status_id, :facet => true
    has listing_status(:name), :as => :listing_status_name, :facet => true
    has "CRC32(cop_state)", :as => :cop_state, :type => :integer # NOTE: This used to have :facet => true, but it broke search in production, and *only* in production - I don't know why, but I do know that this fixes it
    has joined_on, :facet => true
    has delisted_on, :facet => true
    has is_ft_500, :facet => true
    has state, active, participant
    # set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
    set_property :enable_star => true
    set_property :min_prefix_len => 4
  end
  
  # We want to index all organizations, not just participant; so, this scope replaces the index clause below
  # where 'organizations.state = "approved" AND organizations.active = 1 AND organizations.participant = 1' #FIXME: possibly exclude delisted?
  sphinx_scope(:participants_only) { 
    { 
      with: { participant: 1,
              active:      1 }
    }
  }
  
  COP_STATE_ACTIVE = 'active'
  COP_STATE_NONCOMMUNICATING = 'noncommunicating'
  COP_STATE_DELISTED = 'delisted'
  
  COP_STATES = {
    :active => COP_STATE_ACTIVE,
    :noncommunicating => COP_STATE_NONCOMMUNICATING,
    :delisted => COP_STATE_DELISTED
  }
  
  COP_GRACE_PERIOD = 90
  COP_TEMPORARY_PERIOD = 90
  
  # revenue and corresponding pledge amount
  REVENUE = {
    'less than 25 million' => 500,
    'between USD 25 million and 250 million' => 2500,
    'between USD 250 million and USD 1 billion' => 5000,
    'USD 1 billion or more' => 10000
  }
  
  state_machine :cop_state, :initial => :active do
    after_transition :on => :delist, :do => :set_delisted_status
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
  
  named_scope :businesses, {
    :include    => :organization_type,
    :conditions => ["organization_types.type_property = ?", OrganizationType::BUSINESS] 
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
  
  named_scope :created_at, lambda { |month, year|
    { :conditions => ['created_at >= ? AND created_at <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month] }
  }
  
  named_scope :joined_on, lambda { |month, year|
    { :conditions => ['joined_on >= ? AND joined_on <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month] }
  }
  
  named_scope :with_pledge, :conditions => 'pledge_amount > 0'
  
  named_scope :about_to_become_noncommunicating, lambda {
    { conditions: ["cop_state=? AND cop_due_on<=?", COP_STATE_ACTIVE, 1.day.ago.to_date] }
  }

  named_scope :about_to_become_delisted, lambda {
    { conditions: ["cop_state=? AND cop_due_on<=?", COP_STATE_NONCOMMUNICATING, (1.year + 1.day).ago.to_date] }
  }
  
  def set_replied_to(current_user)
    if current_user.from_organization?
      self.replied_to = false
    elsif current_user.from_ungc?
      self.replied_to = true
    end
    
  end
  
  def network_report_recipients
    if self.country.try(:local_network)
      self.country.local_network.contacts.network_report_recipients
    else
      []
    end
  end
  
  def self.find_by_param(param)
    return nil if param.blank?
    # param = CGI.unescape param
    id = param.to_i
    find_by_id(id)
  end
  
  def self.visible_in_local_network
    statuses = [:noncommunicating, :active, :delisted]
    participants.active.with_cop_status(statuses)
  end

  def company?
    organization_type.try(:name) == 'Company' ||
    organization_type.try(:name) == 'SME'
  end

  def academic?
     organization_type.try(:name) == 'Academic'
   end

  def listing_status_name
    listing_status.try(:name) || 'Unknown'
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

  def organization_type_name
    organization_type.try(:name)
  end
  
  def business_for_search
    business_entity? ? 1 : 0
  end
  
  def business_entity?
    organization_type.try(:business?) || micro_enterprise?
  end
  
  # NOTE: Convenient alias
  def noncommed_on; cop_due_on; end

  def invoice_id
    "FGCD#{id}"
  end
  
  def last_modified_by_full_name
    contact_id = last_modified_by_id || reviewer_id
    if contact_id
      Contact.exists?(contact_id) ? Contact.find(contact_id).try(:name) : "Contact ID: #{contact_id} (deleted)"
    else
      'unknown'
    end
  end

  def financial_contact_or_contact_point
    self.contacts.financial_contacts.count > 0 ? self.contacts.financial_contacts.first : self.contacts.contact_points.first
  end

  
  def last_comment_date
    self.try(:comments).try(:last).try(:updated_at) || nil
  end
    
  def last_comment_author
    last_comment = self.try(:comments).try(:last)
    last_comment ? last_comment.try(:contact).try(:name) : ''
  end
    
  def to_param
    string = name
    string = string.gsub(/\W+/, '-')
    string = "#{id}-#{string}"
    string = string.gsub(/-+/, '-')
    string = CGI.escape(string)
  end
  
  def noncommunicating?
    cop_state == COP_STATE_NONCOMMUNICATING
  end

  def active?
    cop_state == COP_STATE_ACTIVE
  end
  
  def delisted?
    cop_state == COP_STATE_DELISTED
  end
  
  
  # Indicates if this organization uses the most recent COP rules
  def joined_after_july_2009?
    joined_on >= Date.new(2009,7,1)
  end
  
  def participant_for_over_5_years?
    joined_on < 5.years.ago.to_date
  end
  
  # Policy specifies 90 days, so we extend the current due date
  def extend_cop_grace_period
    self.update_attribute :cop_due_on, (self.cop_due_on + COP_GRACE_PERIOD.days)
    self.update_attribute :active, true
  end
  
  def extend_cop_temporary_period
    self.update_attribute(:cop_due_on, COP_TEMPORARY_PERIOD.days.from_now)
  end
  
  # COP's next due date is 1 year from current date
  # Organization's participant and cop status are now 'active'
  def set_next_cop_due_date
    self.communication_received
    self.update_attribute :cop_due_on, 1.year.from_now
    self.update_attribute :cop_state, COP_STATE_ACTIVE
    self.update_attribute :active, true
  end
  
  def set_approved_fields
    set_next_cop_due_date
    set_approved_on
  end
  
  def set_rejected_fields
    self.name = self.name + ' (rejected)'
    self.save
  end
  
  def set_network_review
    self.network_review_on = Date.today
    self.save
  end

  def set_approved_on
    self.active = true
    self.participant = true
    self.joined_on = Date.today
    self.save
  end
  
  def set_delisted_status
    self.active = false
    self.removal_reason = RemovalReason.delisted
    self.delisted_on = Date.today
    self.save
  end
  
  def set_manual_delisted_status
    self.update_attribute :cop_state, Organization::COP_STATE_DELISTED if self.participant?
  end
  
  def delisted_on_string=(date_or_string)
    if date_or_string.is_a?(String)
      self.write_attribute(:delisted_on, Date.strptime(date_or_string, '%m/%d/%Y'))
    elsif date_or_string.is_a?(Date)
      self.write_attribute(:delisted_on, date_or_string)
    end
  end

  def delisted_on_string
    (delisted_on || Date.today).strftime('%m/%d/%Y')
  end
  
  # predict delisting date based on current status and COP due date
  # only one year of non-communicating is assumed
  def delisting_on
    return unless company?
    case cop_state
      when COP_STATE_NONCOMMUNICATING
        cop_due_on + 1.year unless cop_due_on.nil?
      when COP_STATE_ACTIVE
        cop_due_on + 2.year unless cop_due_on.nil?
      else
        ''
    end
  end
  
  def reverse_roles

    if self.contacts.ceos.count == 1 && self.contacts.contact_points.count == 1      
      ceo = self.contacts.ceos.first
      contact = self.contacts.contact_points.first
      
      # save ceo login first since we have to change it before reassigning it to the contact point
      # logins must be unique
      ceo_login = contact.login
      
      # make current ceo a contact point
      ceo.roles << Role.contact_point
      
      # logins must be unique, so change the current contact's login
      contact.login = contact.id                
      contact.save
      
      # copy original login
      ceo.login = ceo_login
      
      # copy passwords
      ceo.hashed_password = contact.hashed_password
      ceo.password = contact.password
      ceo.save
      
      # remove login/password from former contact
      contact.roles.delete(Role.contact_point)
      contact.login = nil
      contact.hashed_password = nil
      contact.password = nil
      contact.save                
              
      # the contact person should now be CEO
      contact.roles << Role.ceo
      
      # remove CEO role from contact point
      ceo.roles.delete(Role.ceo)
      true
    else
      self.errors.add_to_base("Sorry, the roles could not be reversed. There can only be one Contact Point and one CEO to reverse roles.")
      false
    end
    
  end
  
  def jci_referral?(url)
     valid_urls = [
       'http://www.jci.cc/media/en/presidentscorner/globalcompact',
       'http://www.jci.cc/media/es/presidentscorner/globalcompact',
       'http://www.jci.cc/media/fr/presidentscorner/globalcompact',
       'http://127.0.0.1:3000/HowToParticipate/How_to_Apply_Business.html'
      ]
      valid_urls.include?(url) ? true : false
  end
  
  private
    
    def set_non_business_sector
      unless self.business_entity?
        self.sector = Sector.not_applicable
      end
    end
    
    def check_micro_enterprise_or_sme
      # we don't make assumptions if there is no employees information
      return if self.employees.nil?
      if self.business_entity?
        if self.employees < 10
          self.organization_type_id = OrganizationType.try(:micro_enterprise).try(:id)
        elsif self.employees < 250
          self.organization_type_id = OrganizationType.try(:sme).try(:id)
        elsif self.employees >= 250
          self.organization_type_id = OrganizationType.try(:company).try(:id)
        end
      end
    end
    
end
