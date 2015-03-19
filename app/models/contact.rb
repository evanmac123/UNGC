# == Schema Information
#
# Table name: contacts
#
#  id                        :integer          not null, primary key
#  old_id                    :integer
#  first_name                :string(255)
#  middle_name               :string(255)
#  last_name                 :string(255)
#  prefix                    :string(255)
#  job_title                 :string(255)
#  email                     :string(255)
#  phone                     :string(255)
#  mobile                    :string(255)
#  fax                       :string(255)
#  organization_id           :integer
#  address                   :string(255)
#  city                      :string(255)
#  state                     :string(255)
#  postal_code               :string(255)
#  country_id                :integer
#  username                  :string(255)
#  address_more              :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token_expires_at :datetime
#  remember_token            :string(255)
#  local_network_id          :integer
#  encrypted_password        :string(255)
#  plaintext_password        :string(255)
#  reset_password_token      :string(255)
#  last_sign_in_at           :datetime
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0)
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  welcome_package           :boolean
#

require 'digest/sha1'

class Contact < ActiveRecord::Base
  include VisibleTo

  devise \
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable

  has_attached_file :image, :styles => {
      :show => "213x277>",
      :'show@2x' => "425x554>",
    },
    :url => "/system/:class/:attachment/:id/:style/:filename"

  do_not_validate_attachment_file_type :image

  TYPE_UNGC = :ungc
  TYPE_ORGANIZATION = :organization
  TYPE_NETWORK = :network
  TYPE_NETWORK_GUEST = :network_guest
  TYPE_REGIONAL = :regional

  # if they haven't logged in then we redirect them to their edit page to confirm their contact information
  MONTHS_SINCE_LOGIN = 6

  validates_presence_of     :prefix, :first_name, :last_name, :job_title, :email, :phone, :address, :city, :country_id
  validates_presence_of     :username, :if => :can_login?
  validates_presence_of     :plaintext_password, :if => :password_required?
  validates_uniqueness_of   :username, :allow_nil => true, :case_sensitive => false, :allow_blank => true
  validates_uniqueness_of   :email, :on => :create
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of       :password, :within => Devise.password_length, :if => :password_required?
  validates_format_of       :email,
                              :with => /\A[A-Za-z0-9.'_%+-]+@[A-Za-z0-9'.-]+\.[A-Za-z]{2,6}\z/,
                              :message => "is not a valid email address"

  belongs_to :country
  belongs_to :organization
  belongs_to :local_network
  has_and_belongs_to_many :roles, :join_table => "contacts_roles"

  default_scope { order('contacts.first_name') }

  # TODO LATER: remove plain text password at some point - attr_accessor :password
  # before_save :encrypt_password

  before_destroy :keep_at_least_one_ceo
  before_destroy :keep_at_least_one_contact_point

  before_update  :do_not_allow_last_contact_point_to_uncheck_role
  before_update  :do_not_allow_last_ceo_to_uncheck_role

  # used for checkbox in sign up form
  # /app/views/signup/step5.html.haml
  attr_accessor :foundation_contact

  scope :participants_only, lambda { where(["organizations.participant = ?", true]) }

  # Attempt to find a user by its email. If a record is found, send new
  # password instructions to it. If user is not found, returns a new user
  # with an email not found error.
  # Attributes must contain the user's email
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted? && recoverable.username.present?
    recoverable
  end

  def self.for_local_network
    includes([:roles, {:organization => [:sector, :country, :organization_type]}, :country])
      .where("contacts_roles.role_id IN (?)", [Role.ceo, Role.contact_point])
      .order("organizations.name")
  end

  def self.financial_contacts
    joins(:roles).merge(Role.financial_contacts).includes(:roles)
  end

  def self.contact_points
    joins(:roles).merge(Role.contact_points).includes(:roles)
  end

  def self.ceos
    joins(:roles).merge(Role.ceos).includes(:roles)
  end

  def self.network_roles
    roles = []
    roles << Role.network_focal_point
    roles << Role.network_representative
    roles << Role.network_report_recipient

    joins(:roles).where("contacts_roles.role_id IN (?)", roles).includes(:roles).order("roles.name DESC")
  end

  def self.network_roles_public
    roles = []
    roles << Role.network_focal_point
    roles << Role.network_representative
    joins(:roles).where("contacts_roles.role_id IN (?)", roles).includes(:roles).order("roles.name DESC")
  end

  def self.network_contacts
    joins(:roles).merge(Role.network_focal_points).includes(:roles).order("roles.name DESC")
  end

  def self.network_representatives
    joins(:roles).merge(Role.network_representatives).includes(:roles).order("roles.name DESC")
  end

  def self.network_report_recipients
    joins(:roles).merge(Role.network_report_recipients).includes(:roles)
  end

  def self.network_regional_managers
    joins(:roles).merge(Role.network_regional_managers).includes(:roles)
  end

  def self.participant_managers
    joins(:roles).merge(Role.participant_managers).includes(:roles)
  end

  scope :for_country, lambda { |country| where(:country_id => country.id) }
  scope :with_login, lambda { where("username IS NOT NULL") }

  def name
    [first_name, last_name].join(' ')
  end

  def full_name_with_title
    [prefix, name].join(' ')
  end

  def name_with_title
    [prefix, last_name].join(' ')
  end

  def email_recipient
    address = Mail::Address.new email.dup
    address.display_name = name.dup
    address.format
  end

  def contact_info
    "#{full_name_with_title}\n#{job_title}\n#{email}\n#{phone}"
  end

  def from_ungc?
    organization_id? && organization.name == DEFAULTS[:ungc_organization_name]
  end

  def from_organization?
    organization_id? && !from_ungc?
  end

  def from_network?
    local_network_id?
  end

  def belongs_to_network?(network)
    local_network_id? && local_network == network
  end

  def from_regional_center?
    from_network? && local_network.regional_center?
  end

  def from_network_guest?
    organization_id? && organization.name == DEFAULTS[:local_network_guest_name]
  end

  def from_rejected_organization?
    organization.try(:rejected?)
  end

  def submit_grace_letter?
    # TODO move this to a presenter for views that depend on it.
    GraceLetterApplication.eligible?(self.organization)
  end

  def submit_reporting_cycle_adjustment?
    # TODO move this to a presenter for views that depend on it.
    ReportingCycleAdjustmentApplication.eligible?(self.organization)
  end

  def organization_delisted_on
    self.organization.delisted_on
  end

  def organization_name(args = {})
    # args are used to skip queries in the reports
    if from_network?
      args.fetch(:local_network_name) { local_network.try(:name) }
    else
      args.fetch(:organization_name) { organization.try(:name) }
    end
  end

  def country_name
    country.try(:name)
  end

  def user_type
    return TYPE_UNGC if from_ungc?
    return TYPE_REGIONAL if from_regional_center?
    return TYPE_NETWORK if from_network?
    return TYPE_NETWORK_GUEST if from_network_guest?
    return TYPE_ORGANIZATION if from_organization?
  end

  def is?(role)
    roles.include? role
  end

  def can_login?
    Role.login_roles.any? { |r| is?(r) }
  end

  def encrypt_password
    return if plaintext_password.blank?
    self.hashed_password = Contact.encrypted_password(password)
  end

  def needs_to_update_contact_info?
    if from_organization?
      last_update = last_sign_in_at || updated_at
      last_update < (Date.today - Contact::MONTHS_SINCE_LOGIN.months)
    end
  end

  def rejected_organization_email
    self.update_attribute :email, "rejected.#{self.email}"
  end

  def last_contact_or_ceo?(role, current_contact)
    if current_contact.from_organization? && !new_record?
      if role == Role.ceo
        return true if self.is?(Role.ceo) && organization.contacts.ceos.count == 1
      elsif role == Role.contact_point
        return true if self.is?(Role.contact_point) && organization.contacts.contact_points.count == 1
      end
    end
  end

  # Overrides Devise::Models::DatabaseAuthenticatable
  def password=(new_password)
    @password = new_password
    if @password.present?
      self.plaintext_password = @password
      self.encrypted_password = password_digest(@password)
    end
  end

  def valid_password?(password)
    begin
      super(password)
    rescue BCrypt::Errors::InvalidHash
      return false unless Contact.old_encrypted_password(password) == encrypted_password
      logger.info "User #{email} is using the old password hashing method, updating attribute."
      self.password = password
      true
    end
  end

  alias :devise_valid_password? :valid_password?

  def self.new_contact_point
    new roles: [Role.contact_point]
  end

  def self.new_financial_contact
    new roles: [Role.financial_contact]
  end

  def self.new_ceo
    new roles: [Role.ceo]
  end

  private

    def password_required?
      return false unless username.present?
      return true if reset_password_token.present? && reset_password_period_valid?
      (!persisted? || !password.nil? || !password_confirmation.nil?)
    end

    def keep_at_least_one_ceo
      if self.is?(Role.ceo) && self.organization.contacts.ceos.count <= 1
        errors.add :base, "cannot delete CEO, at least 1 CEO should be kept at all times"
        return false
      end
    end

    def keep_at_least_one_contact_point
      if self.is?(Role.contact_point) && self.organization.contacts.contact_points.count <= 1
        errors.add :base, "cannot delete Contact Point, at least 1 Contact Point should be kept at all times"
        return false
      end
    end

    def do_not_allow_last_contact_point_to_uncheck_role
      if self.from_organization? && self.organization.participant && self.organization.contacts.contact_points.count < 1
        self.roles << Role.contact_point
      end
    end

    def do_not_allow_last_ceo_to_uncheck_role
      if self.from_organization? && self.organization.participant && !self.is?(Role.ceo) && self.organization.contacts.ceos.count < 1
        self.roles << Role.ceo
      end
    end

    def self.old_encrypted_password(password)
      Digest::SHA1.hexdigest("#{password}--UnGc--")
    end
end
