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
#  no_pledge_reason               :string(255)
#  isin                           :string(255)
#

class Organization < ActiveRecord::Base
  include ApprovalWorkflow
  include Indexable
  include ThinkingSphinx::Scopes

  self.include_root_in_json = false

  validates_presence_of :name
  validates_uniqueness_of :name,
    case_sensitive: false,
    message: "has already been used by another organization"

  validates :employees, numericality: {
    only_integer: true,
    less_than_or_equal_to: 2_147_483_647, # 4 byte column
    message: "Should only contain numbers less than 2,147,483,647. No commas or periods are required.",
  }

  validates_numericality_of :pledge_amount, :only_integer => true, :message => "should only contain numbers. No commas or periods are required.",
                            :if => Proc.new { |organization| organization.pledge_amount.present? }
  validates_format_of :url,
                      :with => (/(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(([0-9]{1,6})?\/.*)?$)/ix),
                      :message => "address is invalid. Please enter one address in the format http://website.com/",
                      :unless => Proc.new { |organization| organization.url.blank? }
  validates_presence_of :stock_symbol, :if => Proc.new { |organization| organization.public_company? }
  validates_presence_of :delisted_on,  :if => Proc.new { |organization| organization.require_delisted_on? }, :on => :update
  validates :isin, length: { is: 12 }, :unless => Proc.new { |organization| organization.isin.blank? }

  has_many :signings
  has_many :initiatives, :through => :signings
  has_many :contacts
  has_many :logo_requests
  has_many :communication_on_progresses
  has_many :contributions
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
                              :legal_status => 'legal_status' }.freeze

  has_one :legal_status, -> { where(attachable_key: ORGANIZATION_FILE_TYPES[:legal_status]) },
    class_name: 'UploadedFile', as: 'attachable', dependent: :destroy

  has_one :recommitment_letter, -> { where(attachable_key: ORGANIZATION_FILE_TYPES[:recommitment_letter]) },
    class_name: 'UploadedFile', as: 'attachable', dependent: :destroy

  has_one :withdrawal_letter, -> { where(attachable_key: ORGANIZATION_FILE_TYPES[:withdrawal_letter]) },
    class_name: 'UploadedFile', as: 'attachable', dependent: :destroy

  attr_accessor :delisting_on

  # if the date is set, then the participant
  # is non-communicating for failing to engage in dialogue
  attr_accessor :non_comm_dialogue

  accepts_nested_attributes_for :contacts, :signings
  acts_as_commentable

  before_create :set_participant_manager
  before_save :check_micro_enterprise_or_sme
  before_save :set_non_business_sector_and_listing_status
  before_save :set_initiative_signatory_sector
  before_destroy :delete_contacts

  has_attached_file :commitment_letter,
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"
  do_not_validate_attachment_file_type :commitment_letter

  cattr_reader :per_page
  @@per_page = 100

  COP_STATE_ACTIVE = 'active'.freeze
  COP_STATE_NONCOMMUNICATING = 'noncommunicating'.freeze
  COP_STATE_DELISTED = 'delisted'.freeze

  COP_STATES = {
    :active => COP_STATE_ACTIVE,
    :noncommunicating => COP_STATE_NONCOMMUNICATING,
    :delisted => COP_STATE_DELISTED
  }.freeze

  COP_TEMPORARY_PERIOD = 90.freeze
  NEXT_BUSINESS_COP_YEAR = 1.freeze
  NEXT_NON_BUSINESS_COP_YEAR = 2.freeze
  EXPULSION_THRESHOLD = 1.year.freeze

  REVENUE_LEVELS = {
    1 => 'less than USD 50 million',
    2 => 'between USD 50 million and USD 250 million',
    3 => 'between USD 250 million and USD 1 billion',
    4 => 'between USD 1 billion and USD 5 billion',
    5 => 'USD 5 billion or more'
  }.freeze

  # Suggested pledge levels for funding models correspond to the revenue level
  # These are hard coded into the pledge form and are included here for reference
  # They may not need to be part of the model and we may be able to remove them

  INDEPENDENT_PLEDGE_LEVELS = {
    1 => 250,
    2 => 5000,
    3 => 10000,
    4 => 15000,
    5 => 15000
  }.freeze

  COLLABORATIVE_PLEDGE_LEVELS = {
    1 => 250,
    2 => 2500,
    3 => 5000,
    4 => 10000,
    5 => 15000
  }.freeze

  INDEPENDENT_MINIMUM_PLEDGE_LEVELS = {
    250  => 'USD 250',
    500  => 'USD 500',
    1000 => 'USD 1000',
    2000 => 'USD 2000',
    2500 => 'USD 2500',
    3000 => 'USD 3000',
    4000 => 'USD 4000'
  }.freeze

  COLLABORATIVE_MINIMUM_PLEDGE_LEVELS = {
    250  => 'USD 250',
    500  => 'USD 500',
    1000 => 'USD 1000',
    2000 => 'USD 2000'
  }.freeze

  # identify why an organization has opted out of pledging during signup
  NO_PLEDGE_REASONS = {
    budget:        'We have not budgeted for a contribution this year',
    financial:     'We are facing financial difficulties',
    state_owned:   'We are a state-owned entity and we are prevented from making donations',
    international: 'We cannot make international payments',
    benefits:      'We would like to see the benefits of participating before making a contribution',
    local_network: 'We are significant contributors to one or more Global Compact Local Networks'
  }.freeze

  # identify why an organization is being reviewed
  REVIEW_REASONS = {
    duplicate:            'Duplicate',
    incomplete_cop:       'Incomplete - Missing COP Statement',
    incomplete_coe:       'Incomplete - Missing COE Statement',
    incomplete_format:    'Incomplete - Incorrect Format',
    incomplete_signature: 'Incomplete - Signature from CEO',
    ceo_verification:     'CEO Verification',
    integrity_measure:    'Integrity Measure',
    local_network:        'Local Network followup',
    microenterprise:      'Micro Enterprise - Verify Employees',
    organization_type:    'Organization Type',
    organization_name:    'Organization Name',
    base_operations:      'Base of Operations',
    ngo_verification:     'NGO Verification',
    purpose_activity:     'Purpose & Activities',
    logo_misuse:          'Logo Misuse'
  }.freeze

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

  scope :active, lambda { where("organizations.active = ?", true) }
  scope :participants, lambda { where("organizations.participant = ?", true) }
  scope :companies_and_smes, lambda { joins(:organization_type).merge(OrganizationType.for_filter(:sme, :companies)).includes(:organization_type) }
  scope :companies, lambda { where("organization_type_id IN (?)", OrganizationType.for_filter(:companies)).includes(:organization_type) }
  scope :smes, lambda { where("organization_type_id IN (?)", OrganizationType.for_filter(:sme).pluck(:id)).includes(:organization_type) }
  scope :businesses, lambda { joins(:organization_type).merge(OrganizationType.business) }
  scope :non_businesses, lambda { joins(:organization_type).merge(OrganizationType.non_business) }
  scope :by_type, lambda { |filter_type| where("organization_type_id IN (?)", OrganizationType.for_filter(filter_type).map(&:id)).includes(:organization_type) }

  scope :for_initiative, lambda { |symbol| joins(:initiatives).where("initiatives.id IN (?)", Initiative.for_filter(symbol).map(&:id)).includes(:initiatives).order("organizations.name ASC") }
  scope :last_joined, lambda { order("joined_on DESC, name DESC") }
  scope :not_delisted, lambda { where("cop_state != ?", COP_STATE_DELISTED) }

  scope :with_cop_due_on, lambda { |date| where(cop_due_on: date) }
  scope :with_inactive_on, lambda { |date| where(inactive_on: date) }
  scope :with_cop_due_between, lambda { |start_date, end_date| where(cop_due_on: start_date..end_date) }
  scope :delisted_between, lambda { |start_date, end_date| where(delisted_on: start_date..end_date) }

  scope :noncommunicating, lambda { where("cop_state = ? AND active = ?", COP_STATE_NONCOMMUNICATING, true).order('cop_due_on') }

  scope :listed, lambda { where("organizations.listing_status_id = ?", ListingStatus.publicly_listed).includes([:country, :exchange, :sector]) }
  scope :without_contacts, lambda { where("not exists(select * from contacts c where c.organization_id = organizations.id)") }

  scope :created_at, lambda { |month, year| where('created_at >= ? AND created_at <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month) }
  scope :joined_on, lambda { |month, year| where('joined_on >= ? AND joined_on <= ?', Date.new(year, month, 1), Date.new(year, month, 1).end_of_month) }

  scope :with_pledge, lambda { where('pledge_amount > 0') }
  scope :about_to_become_noncommunicating, lambda { where("cop_state=? AND cop_due_on<=?", COP_STATE_ACTIVE, Date.today) }
  scope :about_to_become_delisted, lambda { where("cop_state=? AND cop_due_on<=?", COP_STATE_NONCOMMUNICATING, EXPULSION_THRESHOLD.ago.to_date) }

  scope :ready_for_invoice, lambda {where("joined_on >= ? AND joined_on <= ?", 2.days.ago.beginning_of_day, 2.days.ago.end_of_day)}
  scope :not_rejected, lambda { where.not(state: STATE_REJECTED) }

  scope :summary, lambda { includes(:country, :sector, :organization_type) }

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

  def self.withdrew
    where(:cop_state => COP_STATE_DELISTED).where(removal_reason_id: RemovalReason.withdrew.id).includes(:removal_reason)
  end

  sphinx_scope(:search_listed_and_publicly_delisted_participants) do
    {
      with: {
        participant: 1,
        # HACK: include 0 to include organizations with nils in removal_reason_id
        removal_reason_id: [0] + RemovalReason.publicly_delisted.ids,
      }
    }
  end

  def self.listed_and_publicly_delisted
    # publicly deslisted or no removal_reason
    where(removal_reason_id: [nil] + RemovalReason.publicly_delisted.ids)
  end

  def self.publicly_delisted
    where(active: false)
      .where(removal_reason: RemovalReason.publicly_delisted)
      .where.not(cop_state: [COP_STATE_ACTIVE, COP_STATE_NONCOMMUNICATING])
      .order('delisted_on DESC')
  end

  # scopes the organization depending on user_type
  # contacts that belong to an organization should only see organizations that share that organization
  # contacts from a local network should see all the organizations in the same country as their network
  # contacts from UNGC should see every organization
  # no organization should be seen otherwise
  def self.visible_to(user)
    case user.user_type
    when Contact::TYPE_ORGANIZATION
      where(id: user.organization_id)
    when Contact::TYPE_NETWORK || Contact::TYPE_NETWORK_GUEST
      where("organizations.country_id" => user.local_network.country_ids)
    when Contact::TYPE_REGIONAL
      countries_in_same_region = user.local_network.regional_center_countries.map(&:id)
      where('organizations.country_id' => countries_in_same_region)
    when Contact::TYPE_UNGC
      all
    else
      none
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

  def self.applications_under_review
    where("organizations.state NOT IN (?)", [ApprovalWorkflow::STATE_APPROVED,
                                             ApprovalWorkflow::STATE_REJECTED,
                                             ApprovalWorkflow::STATE_REJECTED_MICRO ])
  end

  # this object really doesn't need anymore responsibilities
  # but I'm putting these here in the hopes of replacing the
  # model-backed OrganizationType with an active record enum
  # these methods will have the same signature and can be removed
  # at that time
  def sme?
    organization_type.present? && organization_type == OrganizationType.sme
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

  def review_status_name
    if state == ApprovalWorkflow::STATE_IN_REVIEW && replied_to == false
      'Updated'
    else
      state.humanize
    end
  end

  def set_last_modified_by(current_contact)
    update_attribute :last_modified_by_id, current_contact.id
  end

  def local_network
    country.try(:local_network)
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

  def local_network_url
    if country.try(:local_network)
      country.local_network.url
    end
  end

  def network_report_recipients
    if self.country.try(:local_network)
      self.country.local_network.contacts.network_report_recipients
    else
      Contact.none
    end
  end

  def network_contact_person
    if self.country.try(:local_network)
      self.country.local_network.contacts.network_contacts.first
    else
      [] # TODO none in rails4
    end
  end

  def network_report_recipient_name
    network_report_recipients.first.full_name_with_title
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
    # oddly enough there are cases when type is not set
    organization_type.try(:non_business?)
  end

  def business?
    # oddly enough there are cases when type is not set
    organization_type.try(:business?)
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

  def non_business_type
    if academic?
      'academic'
    elsif city?
      'city'
    elsif labour?
      'labour'
    elsif ngo?
      'ngo'
    elsif business_association?
      'business_association'
    elsif public_sector?
      'public'
    else
      raise 'Invalid non business organization type'
    end
  end

  def is_deleted
    if state == "approved"
      false
    else
      true
    end
  end

  def listing_status_name
    listing_status.try(:name)
  end

  def public_company?
    listing_status.try(:name) == 'Publicly Listed'
  end

  def micro_enterprise?
    organization_type_id == OrganizationType.micro_enterprise.try(:id)
  end

  def signatory_of?(initiative_sym)
    initiative = Initiative.for_filter(initiative_sym).first
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
    if collaborative_funding_model?
      revenue ? COLLABORATIVE_PLEDGE_LEVELS[revenue] : ''
    else
      revenue ? INDEPENDENT_PLEDGE_LEVELS[revenue] : ''
    end
  end

  def no_pledge_reason_value
    NO_PLEDGE_REASONS[no_pledge_reason.to_sym] if no_pledge_reason.present?
  end

  def collaborative_funding_model?
    country.try(:local_network).try(:funding_model) == 'collaborative'
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

  def cop_name
    company? ? "Communication on Progress" : "Communication on Engagement"
  end

  def cop_acronym
    company? ? "COP" : "COE"
  end

  def last_approved_cop
    communication_on_progresses.approved.first if communication_on_progresses.approved.any?
  end

  def last_approved_cop_id
    last_approved_cop.id if last_approved_cop
  end

  def last_approved_cop_year
    last_approved_cop.published_on.year if last_approved_cop
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
    communication_on_progresses.approved.order('published_on DESC').each do |cop|
      next if cop.is_grace_letter? || cop.is_reporting_cycle_adjustment?
      cops << cop if cop.learner?
    end

    # check if the total time between first and last COP is two years
    first_cop   = cops.last
    second_cop  = cops.first
    months_between_cops = (first_cop.published_on.month - second_cop.published_on.month) + 12 * (first_cop.published_on.year - second_cop.published_on.year)
    months_between_cops = months_between_cops.abs
    if months_between_cops == 12
      # same month, so compare date
      first_cop.published_on.day <= second_cop.published_on.day
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

  # FIXME it is very confusing to have .active? refer to cop_state here
  # It is also shadowing the rails-provided method active? for the #active field
  def active?
    cop_state == COP_STATE_ACTIVE
  end

  def delisted?
    cop_state == COP_STATE_DELISTED
  end

  # Is currently expelled. See also: Organization#was_expelled?
  def expelled?
    delisted? && was_expelled?
  end

  def participant_for_less_than_years(years)
    joined_on.to_time.years_since(years) >= Time.now
  end

  def years_until_next_cop_due
    n = company? ? NEXT_BUSINESS_COP_YEAR : NEXT_NON_BUSINESS_COP_YEAR
    n.years
  end

  def extend_cop_temporary_period
    self.update_attribute(:cop_due_on, COP_TEMPORARY_PERIOD.days.from_now)
  end

  # currently, both COPs and COEs get their due date from cop_due_on
  # which is calculated and set to the proper due date for their type (1yr, 2yr...)
  def communication_due_on
    cop_due_on
  end

  # COP's next due date is 1 year from current date, 2 years for non-business
  # Organization's participant and cop status are now 'active', unless they submit a series of Learner COPs
  def set_next_cop_due_date_and_cop_status!(date = nil)
    # communication_received! will set cop_state to active, and we re-adjust after
    next_cop_state = triple_learner_for_one_year? ? COP_STATE_NONCOMMUNICATING : COP_STATE_ACTIVE
    next_cop_due_date = date || years_until_next_cop_due.from_now

    attrs = {
      active: true,
      cop_due_on: next_cop_due_date,
      cop_state: next_cop_state,
    }
    attrs[:rejoined_on] = Date.today if delisted?

    transaction do
      self.communication_received! if can_communication_received?
      self.update!(attrs)
    end
  end

  def can_submit_cop?
    if active? || noncommunicating? || delisted_on.blank?
      return true
    end

    if was_expelled? || voluntarily_withdrawn?
      # if a new Letter of Commitment was uploaded, then they can submit a COP
      return recommitted?
    end

    false
  end

  def set_approved_fields
    set_next_cop_due_date_and_cop_status!
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
    self.active = false if participant?
  end

  # predict delisting date based on current status and COP due date
  # only one year of non-communicating is assumed
  def delisting_on
    if cop_due_on.nil? || delisted?
      nil
    else
      cop_due_on + EXPULSION_THRESHOLD
    end
  end

  def projected_expulsion_date
    delisting_on
  end

  def non_comm_dialogue
    non_comm_dialogue_on.present?
  end

  def participant_has_submitted_differentiation_cop
    if communication_on_progresses.approved.count > 0
      communication_on_progresses.approved.first.is_differentiation_program?
    end
  end

  def differentiation_level
    if communication_on_progresses.approved.count > 0
      if last_approved_cop.evaluated_for_differentiation?
        'GC ' + last_approved_cop.differentiation_level_public.titleize
      end
    end
  end

  def mission_statement?
    if non_business?
      non_business_organization_registration && non_business_organization_registration.mission_statement.present?
    end
  end

  def reverse_roles
    if self.contacts.ceos.count == 1 && self.contacts.contact_points.count == 1
      RoleReverser.reverse(
        ceo: self.contacts.ceos.first,
        contact_point: self.contacts.contact_points.first
      )
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

  # create methods linke :legal_status_file and :legal_status_file=
  # so we can set the attachment in the organization object
  [:legal_status, :recommitment_letter, :withdrawal_letter].each do |type|

    name = "#{type}_file="
    define_method name do |attachment|
      self.send "build_#{type}", attachment: attachment
    end

    name = "#{type}_file"
    define_method name do
      self.send "#{type}.attachment"
    end

  end

  def registration
    if non_business?
      non_business_organization_registration || build_non_business_organization_registration
    else
      @business_organization_registration ||= BusinessOrganizationRegistration.new
    end
  end

  def error_message
    errors.full_messages.to_sentence
  end

  private

    def set_participant_manager
      if country && country.participant_manager
        self.participant_manager_id = country.participant_manager.id
      end
    end

    def set_non_business_sector_and_listing_status
      unless business_entity? || initiative_signatory?
        self.sector = Sector.not_applicable
        self.listing_status = ListingStatus.not_applicable
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
        self.organization_type_id = if employees < 10 && !approved?
          OrganizationType.try(:micro_enterprise).try(:id)
        elsif employees < 250
          OrganizationType.try(:sme).try(:id)
        elsif employees >= 250
          OrganizationType.try(:company).try(:id)
        end
      end
    end

    def delete_contacts
      contacts.each do |c|
        c.roles.delete_all
        c.delete
      end
    end

    # Is currently, or has previously been, expelled
    def was_expelled?
      delisted_on.present? && removal_reason == RemovalReason.delisted
    end

    # Is currently, or has previously withdrawn
    def voluntarily_withdrawn?
      delisted_on.present? && removal_reason == RemovalReason.withdrew
    end

    def recommitted?
      recommitment_letter && recommitment_letter.updated_at > delisted_on
    end
end
