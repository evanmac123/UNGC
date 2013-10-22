# == Schema Information
#
# Table name: organizations
#
#  id                             :integer          not null, primary key
#  old_id                         :integer
#  name                           :string(255)
#  organization_type_id           :integer
#  sector_id                      :integer
#  participant                    :boolean
#  employees                      :integer
#  url                            :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#  joined_on                      :date
#  delisted_on                    :date
#  active                         :boolean
#  country_id                     :integer
#  stock_symbol                   :string(255)
#  removal_reason_id              :integer
#  last_modified_by_id            :integer
#  state                          :string(255)
#  exchange_id                    :integer
#  listing_status_id              :integer
#  is_ft_500                      :boolean
#  cop_due_on                     :date
#  inactive_on                    :date
#  commitment_letter_file_name    :string(255)
#  commitment_letter_content_type :string(255)
#  commitment_letter_file_size    :integer
#  commitment_letter_updated_at   :datetime
#  pledge_amount                  :integer
#  cop_state                      :string(255)
#  replied_to                     :boolean
#  reviewer_id                    :integer
#  bhr_url                        :string(255)
#  rejected_on                    :date
#  network_review_on              :date
#  revenue                        :integer
#  rejoined_on                    :date
#  non_comm_dialogue_on           :date
#  review_reason                  :string(255)
#  participant_manager_id         :integer
#  is_local_network_member        :boolean
#  is_landmine                    :boolean
#  is_tobacco                     :boolean
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

  has_one :non_business_organization_registration

  ORGANIZATION_FILE_TYPES = { :commitment_letter => 'commitment_letter', # this has to be migrated first
                              :recommitment_letter => 'recommitment_letter',
                              :withdrawal_letter => 'withdrawal_letter',
                              :legal_status => 'legal_status' }

  has_one :legal_status, :class_name => 'UploadedFile', :as => 'attachable',
            :conditions => {:attachable_key => ORGANIZATION_FILE_TYPES[:legal_status]}, :dependent => :destroy
  has_one :recommitment_letter, :class_name => 'UploadedFile', :as => 'attachable',
            :conditions => {:attachable_key => ORGANIZATION_FILE_TYPES[:recommitment_letter]}, :dependent => :destroy
  has_one :withdrawal_letter, :class_name => 'UploadedFile', :as => 'attachable',
            :conditions => {:attachable_key => ORGANIZATION_FILE_TYPES[:withdrawal_letter]}, :dependent => :destroy

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
    1 => 100,
    2 => 5000,
    3 => 10000,
    4 => 15000,
    5 => 15000
  }

  MINIMUM_PLEDGE_LEVELS = {
    100  => 'USD 100',
    250  => 'USD 250',
    500  => 'USD 500',
    1000 => 'USD 1000',
    2000 => 'USD 2000',
    2500 => 'USD 2500',
    3000 => 'USD 3000',
    4000 => 'USD 4000'
  }

  # identify why an organization is being reviewed
  REVIEW_REASONS = {
    :duplicate            => 'Duplicate',
    :incomplete_cop       => 'Incomplete - Missing COP Statement',
    :incomplete_format    => 'Incomplete - Incorrect Format',
    :incomplete_signature => 'Incomplete - Signature from CEO',
    :integrity_measure    => 'Integrity Measure',
    :local_network        => 'Local Network followup',
    :microenterprise      => 'Micro Enterprise - Verify Employees',
    :organization_type    => 'Organization Type',
    :organization_name    => 'Organization Name',
    :base_operations      => 'Base of Operations',
    :ngo_verification     => 'NGO Verification',
    :purpose_activity     => 'Purpose & Activities',
    :logo_misuse          => 'Logo Misuse'
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
      transition :from => [:noncommunicating, :delisted], :to => :active
    end
  end

  scope :active, where("organizations.active = ?", true)
  scope :participants, where("organizations.participant = ?", true)
  scope :withdrew, where(:cop_state => COP_STATE_DELISTED).where(removal_reason_id: RemovalReason.withdrew).includes(:removal_reason)
  scope :companies_and_smes, lambda { where("organization_type_id IN (?)", OrganizationType.for_filter(:sme, :companies)).includes(:organization_type) }
  scope :companies, lambda { where("organization_type_id IN (?)", OrganizationType.for_filter(:companies)).includes(:organization_type) }
  scope :smes, lambda { where("organization_type_id IN (?)", OrganizationType.for_filter(:sme)).includes(:organization_type) }
  scope :businesses, lambda { where("organization_types.type_property = ?", OrganizationType::BUSINESS).includes(:organization_type) }
  scope :by_type, lambda { |filter_type| where("organization_type_id IN (?)", OrganizationType.for_filter(filter_type).map(&:id)).includes(:organization_type) }

  scope :for_initiative, lambda { |symbol| where("initiatives.id IN (?)", Initiative.for_filter(symbol).map(&:id)).includes(:initiatives).order("organizations.name ASC") }
  scope :last_joined, order("joined_on DESC, name DESC")
  scope :not_delisted, where("cop_state != ?", COP_STATE_DELISTED)

  scope :with_cop_due_on, lambda { |date| where(cop_due_on: date) }
  scope :with_cop_due_between, lambda { |start_date, end_date| where(cop_due_on: start_date..end_date) }
  scope :delisted_between, lambda { |start_date, end_date| where(delisted_on: start_date..end_date) }

  scope :noncommunicating, where("cop_state = ? AND active = ?", COP_STATE_NONCOMMUNICATING, true).order('cop_due_on')

  scope :expelled_for_failure_to_communicate_progress, where("organizations.removal_reason_id = ? AND active = ? AND cop_state NOT IN (?)", RemovalReason.for_filter(:delisted).map(&:id), false, [COP_STATE_ACTIVE, COP_STATE_NONCOMMUNICATING]).order('delisted_on DESC')

  scope :listed, where("organizations.stock_symbol IS NOT NULL").includes([:country, :exchange])
  scope :without_contacts, where("not exists(select * from contacts c where c.organization_id = organizations.id)")

  scope :created_at, lambda { |month, year| where('created_at >= ? AND created_at <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month) }
  scope :joined_on, lambda { |month, year| where('joined_on >= ? AND joined_on <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month) }

  scope :with_pledge, where('pledge_amount > 0')
  scope :about_to_become_noncommunicating, lambda { where("cop_state=? AND cop_due_on<=?", COP_STATE_ACTIVE, 1.day.ago.to_date) }
  scope :about_to_become_delisted, lambda { where("cop_state=? AND cop_due_on<=?", COP_STATE_NONCOMMUNICATING, 1.year.ago.to_date) }

  scope :ready_for_invoice, lambda {where("joined_on >= ? AND joined_on <= ?", 1.day.ago.beginning_of_day, 1.day.ago.end_of_day)}

  def self.with_cop_status(filter_type)
    if filter_type.is_a?(Array)
      statuses = filter_type.map { |t| COP_STATES[t] }
      where("cop_state IN (?)", statuses)
    else
      where("cop_state = ?", COP_STATES[filter_type])
    end
  end

  def self.with_cop_info
    select("organizations.*, c.*")
      .joins("LEFT JOIN (
              SELECT
                organization_id,
                MAX(created_at) AS latest_cop,
                COUNT(id) AS cop_count
              FROM
                communication_on_progresses
              WHERE
                state = 'approved'
              GROUP BY
                 organization_id ) as c ON organizations.id = c.organization_id")
      .includes([:organization_type, :country, :exchange, :listing_status, :sector, :communication_on_progresses])
  end


  def self.visible_to(user)
    if user.user_type == Contact::TYPE_ORGANIZATION
      where('id=?', user.organization_id)
    elsif user.user_type == Contact::TYPE_NETWORK
      where("country_id in (?)", user.local_network.country_ids)
    else
      self.scoped({})
    end
  end

  def self.where_country_id(id_or_array)
    if id_or_array.is_a?(Array)
      where('country_id IN (?)', id_or_array)
    else
      where(:country_id => id_or_array)
    end
  end

  def self.peer_organizations(organization)
    conditions = ["country_id = ? AND sector_id = ? AND organizations.id != ?", organization.country_id, organization.sector_id, organization.id]
    unless organization.company?
      conditions = ["country_id = ? AND organization_type_id = ? AND organizations.id != ?", organization.country_id, organization.organization_type_id, organization.id]
    end
    where(conditions).includes([:country, :sector]).order("organizations.name ASC")
  end

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

  def set_replied_to(current_contact)
    if current_contact.from_organization?
      self.replied_to = false
    elsif current_contact.from_ungc?
      self.replied_to = true
    end
  end

  def set_last_modified_by(current_contact)
    update_attribute :last_modified_by_id, current_contact.id
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

  def non_business?
    organization_type.non_business?
  end

  def academic?
    organization_type == OrganizationType.academic
  end

  def city?
    organization_type == OrganizationType.city
  end

  def labour?
    OrganizationType.labour.include? organization_type
  end

  def ngo?
    OrganizationType.ngo.include? organization_type
  end

  def business_association?
    OrganizationType.business_association.include? organization_type
  end

  def public_sector?
    organization_type == OrganizationType.public_sector
  end

  def organization_type_name_for_custom_links
    if company?
      'business'
    elsif academic?
      'academic'
    elsif city?
      'city'
    else
      'non_business'
    end
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

  def contributor_for_year?(year)
    initiative = Initiative.contributor_for_year(year).first
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
    participant_manager.try(:full_name_with_title) || ''
  end

  def participant_manager_email
    participant_manager.try(:email) || ''
  end

  def participant_manager_phone
    participant_manager.try(:phone) || ''
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
    comments.first.updated_at if comments.any?
  end

  def last_comment_author
    comments.first.contact.name if comments.any?
  end

  def review_reason_value
    REVIEW_REASONS[review_reason.to_sym] if review_reason.present?
  end

  def review_reason_to_sym
    review_reason.try(:to_sym)
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

  def triple_learner_for_one_year?

    return false if communication_on_progresses.approved.count < 3

    return false unless communication_on_progresses[0].learner? &&
                        communication_on_progresses[1].learner? &&
                        communication_on_progresses[2].learner?

    # gather learner COPs
    cops = []
    communication_on_progresses.approved.all(:order => 'created_at DESC').each do |cop|
      next if cop.is_grace_letter? || cop.is_reporting_adjustment?
      cops << cop if cop.learner?
    end

    # check if the total time between first and last COP is two years
    first_cop   = cops.last
    second_cop  = cops.first
    months_between_cops = (first_cop.created_at.month - second_cop.created_at.month) + 12 * (first_cop.created_at.year - second_cop.created_at.year)
    months_between_cops = months_between_cops.abs
    if months_between_cops == 12
      # same month, so compare date
      first_cop.created_at.day <= second_cop.created_at.day
    else
      months_between_cops >= 12
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

  # Participants were eligible to contribute starting in 2006
  def initial_contribution_year
    joined_on.year > 2006 ? joined_on.year : 2006
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
  # Organization's participant and cop status are now 'active', unless they submit a series of Learner COPs
  def set_next_cop_due_date_and_cop_status
    self.update_attribute :rejoined_on, Date.today if delisted?
    self.communication_received
    self.update_attribute :cop_due_on, 1.year.from_now
    self.update_attribute :active, true
    self.update_attribute :cop_state, triple_learner_for_one_year? ? COP_STATE_NONCOMMUNICATING : COP_STATE_ACTIVE
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
    set_next_cop_due_date_and_cop_status
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

  # called after OrganizationMailer.reject_microenterprise
  def set_rejected_names
    self.update_attribute :name, name + ' (rejected)'
    self.contacts.each {|c| c.rejected_organization_email}
  end

  def set_network_review
    self.network_review_on = Date.today
    self.review_reason = nil
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
          'Global Compact Learner'
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

      ceo.username = contact.username
      ceo.roles << Role.contact_point
      ceo.encrypted_password = contact.encrypted_password
      ceo.plaintext_password = contact.plaintext_password

      # remove login/password from former contact
      contact.roles.delete(Role.contact_point)
      contact.username = nil
      contact.encrypted_password = nil
      contact.plaintext_password = nil
      contact.save

      # save ceo after contact to avoid username collision
      ceo.save

      # the contact person should now be CEO
      contact.roles << Role.ceo

      # remove CEO role from contact point
      ceo.roles.delete(Role.ceo)
      true
    else
      self.errors.add :base,("Sorry, the roles could not be reversed. There can only be one Contact Point and one CEO to reverse roles.")
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

  def welcome_package?
    contacts.ceos.first.try(:welcome_package)
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
