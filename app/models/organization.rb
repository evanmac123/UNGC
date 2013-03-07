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
#  cop_state                      :string(255)
#  replied_to                     :boolean(1)
#  reviewer_id                    :integer(4)
#  bhr_url                        :string(255)
#  rejected_on                    :date
#  network_review_on              :date
#  revenue                        :integer(4)
#  rejoined_on                    :date
#  non_comm_dialogue_on           :date
#  review_reason                  :string(255)
#  participant_manager_id         :integer(4)
#

class Organization < ActiveRecord::Base
  include ApprovalWorkflow
  self.include_root_in_json = false

  validates_presence_of :name
  validates_uniqueness_of :name, :message => "has already been used by another organization"
  validates_numericality_of :employees, :only_integer => true, :message => "should only contain numbers. No commas or periods are required."
  validates_format_of :url,
                      :with => (/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(([0-9]{1,6})?\/.*)?$)/ix),
                      :message => "for website is invalid. Please enter one address in the format http://unglobalcompact.org/",
                      :unless => Proc.new { |organization| organization.url.blank? }
  validates_presence_of :stock_symbol, :if => Proc.new { |organization| organization.public_company? }
  validates_presence_of :delisted_on,  :if => Proc.new { |organization| organization.require_delisted_on? }, :on => :update

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
  belongs_to :participant_manager, :class_name => 'Contact'

  attr_accessor :delisting_on

  # if the date is set, then the participant
  # is non-communicating for failing to engage in dialogue
  attr_accessor :non_comm_dialogue

  accepts_nested_attributes_for :contacts, :signings
  acts_as_commentable

  before_create :set_participant_manager
  before_save :check_micro_enterprise_or_sme
  before_save :set_non_business_sector
  before_save :set_initiative_signatory_sector
  before_destroy :delete_contacts

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

  REVENUE_LEVELS = {
    1 => 'less than USD 50 million',
    2 => 'between USD 50 million and USD 250 million',
    3 => 'between USD 250 million and USD 1 billion',
    4 => 'between USD 1 billion and USD 10 billion',
    5 => 'USD 10 billion or more'
  }

  # suggested pledge level corresponds to revenue level
  PLEDGE_LEVELS = {
    1 => 0,
    2 => 5000,
    3 => 10000,
    4 => 15000,
    5 => 15000
  }

  # identify why an organization is being reviewed
  REVIEW_REASONS = {
    :duplicate            => 'Duplicate',
    :incomplete_cop       => 'Incomplete - Missing COP Statement',
    :incomplete_format    => 'Incomplete - Incorrect Format',
    :incomplete_signature => 'Incomplete - Signature from CEO',
    :integrity_measure    => 'Integrity Measure',
    :local_network        => 'Local Network followup',
    :microenterprise      => 'Micro Enterprise - Verify Employees'
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

  named_scope :active,
    { :conditions => ["organizations.active = ?", true] }

  named_scope :participants,
    { :conditions => ["organizations.participant = ?", true] }

  named_scope :with_cop_info, {
    :include => [:organization_type, :country, :exchange, :listing_status, :sector, :communication_on_progresses],
                 :select => 'organizations.*, c.*',
                 :joins => "LEFT JOIN (
                            SELECT
                              organization_id,
                              MAX(created_at) AS latest_cop,
                              COUNT(id) AS cop_count
                            FROM
                              communication_on_progresses
                            WHERE
                              state = 'approved'
                            GROUP BY
                               organization_id ) as c ON organizations.id = c.organization_id"
  }

  named_scope :withdrew, {
   :include => :removal_reason,
   :conditions => {:cop_state => COP_STATE_DELISTED, :removal_reason_id => RemovalReason.withdrew }
  }

  named_scope :companies_and_smes, {
    :include => :organization_type,
    :conditions => ["organization_type_id IN (?)", OrganizationType.for_filter(:sme, :companies) ]
  }

  named_scope :companies, {
    :include => :organization_type,
    :conditions => ["organization_type_id IN (?)", OrganizationType.for_filter(:companies) ]
  }

  named_scope :smes, {
    :include => :organization_type,
    :conditions => ["organization_type_id IN (?)", OrganizationType.for_filter(:sme) ]
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

  named_scope :not_delisted,
    { :conditions => ["cop_state != ?", COP_STATE_DELISTED] }

  named_scope :with_cop_due_on, lambda { |date|
    { :conditions => {:cop_due_on => date} }
  }

  named_scope :with_cop_due_between, lambda { |start_date, end_date| {
      :conditions => { :cop_due_on => start_date..end_date }
    }
  }

  named_scope :delisted_between, lambda { |start_date, end_date| {
      :conditions => { :delisted_on => start_date..end_date }
    }
  }

  named_scope :noncommunicating,
    { :conditions => ["cop_state = ? AND active = ?", COP_STATE_NONCOMMUNICATING, true],
      :order => 'cop_due_on'
    }

  named_scope :expelled_for_failure_to_communicate_progress, {
    :conditions => ["organizations.removal_reason_id = ? AND active = ? AND cop_state NOT IN (?)", RemovalReason.for_filter(:delisted).map(&:id), false, [COP_STATE_ACTIVE, COP_STATE_NONCOMMUNICATING] ],
    :order => 'delisted_on DESC'
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
    { :include => [:country, :exchange],
      :conditions => "organizations.stock_symbol IS NOT NULL" }

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
    { conditions: ["cop_state=? AND cop_due_on<=?", COP_STATE_NONCOMMUNICATING, 1.year.ago.to_date] }
  }

  named_scope :peer_organizations, lambda { |organization|
    conditions = ["country_id = ? AND sector_id = ? AND organizations.id != ?", organization.country_id, organization.sector_id, organization.id]
    unless organization.company?
      conditions = ["country_id = ? AND organization_type_id = ? AND organizations.id != ?", organization.country_id, organization.organization_type_id, organization.id]
    end
    {
      :include    => [:country, :sector],
      :conditions => conditions,
      :order      => "organizations.name ASC"
    }
  }

  def as_json(options={})
    only = ['id', 'name', 'participant']
    only += Array(options[:only]) if options[:only]

    methods = ['sector_name', 'country_name']
    methods += Array(options[:methods]) if options[:methods]

    if options[:extras]
      options[:extras].each do |extra|
        self.respond_to?(extra) ? methods << extra : only << extra
      end
    end

    super(:only => only, :methods => methods)
  end

  def set_replied_to(current_user)
    if current_user.from_organization?
      self.replied_to = false
    elsif current_user.from_ungc?
      self.replied_to = true
    end
  end

  def set_last_modified_by(current_user)
    update_attribute :last_modified_by_id, current_user.id
  end

  def local_network_country_code
    if country.try(:local_network)
      country.local_network.country_code
    end
  end

  def local_network_name
    if country.try(:local_network)
      country.local_network.name
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

  def signatory_of?(initiative)
    initiative = Initiative.for_filter(initiative).first
    initiative ? initiative_ids.include?(initiative.id) : false
  end

  def country_name
    country.try(:name)
  end

  def region_name
    country.try(:region_name)
  end

  def sector_name
    sector.try(:name)
  end

  def organization_type_name
    organization_type.try(:name)
  end

  def participant_manager_name
    participant_manager.try(:name) || ''
  end

  def participant_manager_email
    participant_manager.try(:email) || ''
  end

  def revenue_description
    revenue ? REVENUE_LEVELS[revenue] : ''
  end

  def suggested_pledge
    revenue ? PLEDGE_LEVELS[revenue] : ''
  end

  def business_for_search
    business_entity? ? 1 : 0
  end

  def business_entity?
    organization_type.try(:business?) || micro_enterprise?
  end

  # to identify non-participants that were added as signatories
  def initiative_signatory?
    organization_type_id == OrganizationType.signatory.try(:id)
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
    contacts.financial_contacts.any? ? contacts.financial_contacts.first : contacts.contact_points.first
  end

  # if the contact person is also the financial contact, just return the one contact
  def financial_contact_and_contact_point
    return_contacts = []
    return_contacts << contacts.contact_points.first
    if contacts.financial_contacts.any?
      unless return_contacts.include?(contacts.financial_contacts.first)
        return_contacts << contacts.financial_contacts.first
      end
    end
    return_contacts
  end

  def last_comment_date
    self.try(:comments).try(:last).try(:updated_at) || nil
  end

  def last_comment_author
    last_comment = self.try(:comments).try(:last)
    last_comment ? last_comment.try(:contact).try(:name) : ''
  end

  def review_reason_value
    REVIEW_REASONS[review_reason.to_sym] if review_reason.present?
  end

  def review_reason_to_sym
    review_reason.try(:to_sym)
  end

  def review_status(user)
    if review_reason.present? && user.from_ungc?
      "#{state.humanize} (#{review_reason_value})"
    else
      state.humanize
    end
  end

  def to_param
    string = name
    string = string.gsub(/\W+/, '-')
    string = "#{id}-#{string}"
    string = string.gsub(/-+/, '-')
    string = CGI.escape(string)
  end

  def last_approved_cop
    communication_on_progresses.approved.first if communication_on_progresses.approved.any?
  end

  def last_approved_cop_id
    last_approved_cop.id if last_approved_cop
  end

  def last_approved_cop_year
    last_approved_cop.created_at.year if last_approved_cop
  end

  def last_cop_is_learner?
    last_approved_cop && last_approved_cop.learner?
  end

  # last two COPs were Learner
  def double_learner?
    if last_cop_is_learner? && communication_on_progresses.approved.count > 1
      communication_on_progresses[1].learner?
    end
  end

  def rejected?
    state == ApprovalWorkflow::STATE_REJECTED
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

  def was_expelled?
    delisted_on.present? && removal_reason == RemovalReason.delisted
  end

  # Indicates if this organization uses the most recent COP rules
  def joined_after_july_2009?
    joined_on >= Date.new(2009,7,1)
  end

  def participant_for_over_5_years?
    joined_on < 5.years.ago.to_date
  end

  def participant_for_less_than_years(years)
    joined_on.to_time.years_since(years) >= Time.now
  end

  # Policy specifies 90 days, so we extend the current due date
  def extend_cop_grace_period
    self.update_attribute :cop_due_on, (self.cop_due_on + COP_GRACE_PERIOD.days)
    self.update_attribute :active, true
  end

  def extend_cop_temporary_period
    self.update_attribute(:cop_due_on, COP_TEMPORARY_PERIOD.days.from_now)
  end

  def extend_cop_due_date_by_one_year
    self.update_attribute(:cop_due_on, cop_due_on + 1.year)
  end

  # COP's next due date is 1 year from current date
  # Organization's participant and cop status are now 'active'
  def set_next_cop_due_date
    self.update_attribute :rejoined_on, Date.today if delisted?
    self.communication_received
    self.update_attribute :cop_due_on, 1.year.from_now
    self.update_attribute :cop_state, COP_STATE_ACTIVE
    self.update_attribute :active, true
  end

  def can_submit_grace_letter?

    # companies cannot submit two grace letters in a row
    if communication_on_progresses.approved.any?
      if communication_on_progresses.approved.first.is_grace_letter?
        return false
      end
    end

    if delisted?
      return false
    end

    return true
  end

  def can_submit_cop?
    if active? || noncommunicating? || delisted_on.blank?
      return true
    end

    if was_expelled?
      # if a new Letter of Commitment was uploaded, then they can submit a COP
      commitment_letter_updated_at.present? && commitment_letter_updated_at > delisted_on ? true : false
    end

  end

  def set_approved_fields
    set_next_cop_due_date
    set_approved_on
  end

  def set_non_participant_fields
    self.organization_type = OrganizationType.signatory
    self.state = ApprovalWorkflow::STATE_APPROVED
    self.participant = false
    self.active = false
  end

  def set_rejected_fields
    self.rejected_on = Date.today
    self.save
  end

  # called after OrganizationMailer.deliver_reject_microenterprise
  def set_rejected_names
    self.update_attribute :name, name + ' (rejected)'
    self.contacts.each {|c| c.rejected_organization_email}
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
    self.update_attribute :active, false
    self.update_attribute :removal_reason, RemovalReason.delisted
    self.update_attribute :delisted_on, Date.today
  end

  def set_manual_delisted_status
    self.cop_state = Organization::COP_STATE_DELISTED if participant?
  end

  # predict delisting date based on current status and COP due date
  # only one year of non-communicating is assumed
  def delisting_on
    if cop_state == COP_STATE_DELISTED
      nil
    else
      cop_due_on + 1.year unless cop_due_on.nil?
    end
  end

  def non_comm_dialogue
    non_comm_dialogue_on.present?
  end

  def participant_has_submitted_differentiation_cop
    if communication_on_progresses.approved.count > 0
      communication_on_progresses.approved.first.is_differentiation_program?
    end
  end

  def status_name

    # Non-businesses are not assigned these labels
    unless company?
      return cop_state.humanize
    end

    # New company that has not submitted a COP within their first year, or within two years is they joined after July 2009
    if  (participant_for_less_than_years(1) && communication_on_progresses.count == 0) ||
        (!joined_after_july_2009? && participant_for_less_than_years(2) && communication_on_progresses.count == 0)
      return 'New'
    end

    # Company has submitted a COP
    if communication_on_progresses.approved.count > 0

      case last_approved_cop.differentiation
        when 'blueprint'
          'Global Compact Advanced'
        when 'advanced'
          'Global Compact Advanced'
        when 'active'
          'Global Compact Active'
        when 'learner'
          'Global Compact Active'
        else
          'not available'
        end

    else
      'A Communication on Progress has not been submitted'
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
       'http://www.jci.cc/media/en/presidentscorner/unglobalcompact',
       'http://www.jci.cc/media/es/presidentscorner/unglobalcompact',
       'http://www.jci.cc/media/fr/presidentscorner/unglobalcompact'
      ]
      valid_urls.include?(url)
  end

  def require_delisted_on?
    active == false && cop_state == COP_STATE_DELISTED
  end

  private

    def set_participant_manager
      if country && country.participant_manager
        self.participant_manager_id = country.participant_manager.id
      end
    end

    def set_non_business_sector
      unless business_entity? || initiative_signatory?
        self.sector = Sector.not_applicable
      end
    end

    def set_initiative_signatory_sector
      if initiative_signatory? && sector.nil?
        self.sector = Sector.not_applicable
      end
    end

    def check_micro_enterprise_or_sme
      # we don't make assumptions if there is no employee information
      return if employees.nil?
      if business_entity?
        if employees < 10 && !approved?
          self.organization_type_id = OrganizationType.try(:micro_enterprise).try(:id)
        elsif employees < 250
          self.organization_type_id = OrganizationType.try(:sme).try(:id)
        elsif employees >= 250
          self.organization_type_id = OrganizationType.try(:company).try(:id)
        end
      end
    end

    def delete_contacts
      contacts.each do |c|
        c.roles.delete_all
        c.delete
      end
    end

end
