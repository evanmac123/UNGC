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
#  old_encrypted_password    :string(255)
#  reset_password_token      :string(255)
#  last_sign_in_at           :datetime
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0)
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  welcome_package           :boolean
#  image_file_name           :string(255)
#  image_content_type        :string(255)
#  image_file_size           :integer
#  image_updated_at          :datetime
#  encrypted_password        :string(255)
#  last_password_changed_at  :datetime
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
      :show => "250x250>",
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
  STRONG_PASSWORD_POLICY_DATE = Date.new(2016, 9, 7)

  validates_presence_of     :prefix, :first_name, :email, :last_name, :job_title, :address, :city, :country
  validates_presence_of     :phone, unless: :from_ungc?
  validates_presence_of     :username, :if => :can_login?
  validates_presence_of     :password, :if => :password_required?
  validates_uniqueness_of   :username, :allow_nil => true, :case_sensitive => false, :allow_blank => true
  validates_uniqueness_of   :email,
                            :on => :create
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of       :password, :within => Devise.password_length, :if => :password_required?
  validates_format_of       :email,
                              :with => /\A[A-Za-z0-9.'_%+-]+@[A-Za-z0-9'.-]+\.[A-Za-z]{2,6}\z/,
                              :message => "is not a valid email address"
  validates_with PasswordStrengthValidator, :if => :password_required?

  belongs_to :country
  belongs_to :organization
  belongs_to :local_network
  has_many :contacts_roles, inverse_of: :contact
  has_many :roles, through: :contacts_roles do
    def << (role)
      # Prevent duplicate role assignments
      super(role) unless include?(role)
    end
  end



  has_many :cop_log_entries, dependent: :nullify
  has_one :crm_owner, class_name: "Crm::Owner"
  has_one :igloo_user, dependent: :destroy
  has_many :due_diligence_reviews, class_name: DueDiligence::Review, foreign_key: :requester_id

  default_scope { order('contacts.first_name') }

  before_destroy :keep_at_least_one_ceo
  before_destroy :keep_at_least_one_contact_point

  before_update  :do_not_allow_last_contact_point_to_uncheck_role
  before_update  :do_not_allow_last_ceo_to_uncheck_role
  before_update  :mark_passwords_as_updated

  after_commit Crm::CommitHooks.new(:create), on: :create
  after_commit Crm::CommitHooks.new(:update), on: :update
  after_commit Crm::CommitHooks.new(:destroy), on: :destroy

  scope :participants_only, -> { joins(:organization).where(organizations: { participant: true }) }
  scope :ungc_staff, -> { joins(:organization).where(organizations: { name: DEFAULTS[:ungc_organization_name] }) }
  scope :contact_points, -> { for_roles(Role.contact_point) }

  # Attempt to find a user by its email. If a record is found, send new
  # password instructions to it. If user is not found, returns a new user
  # with an email not found error.
  # Attributes must contain the user's email
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted? && recoverable.username.present?
    recoverable
  end

  def self.for_roles(*roles)
    joins(contacts_roles: :role)
        .where(contacts_roles: { role_id: roles })
        .order("roles.name DESC, contacts.id")
  end

  def self.financial_contacts
    for_roles(Role.financial_contact)
  end

  def self.ceos
    for_roles(Role.ceo)
  end


  def self.network_roles
    roles = [
        Role.network_focal_point,
        Role.network_representative,
        Role.network_report_recipient,
    ].freeze

    for_roles(roles)
  end

  def self.network_contacts
    for_roles(Role.network_focal_point)
  end

  def self.network_regional_managers
    for_roles(Role.network_regional_manager)
  end

  def self.participant_managers
    for_roles(Role.participant_manager)
  end

  scope :for_country, lambda { |country| where(country_id: country.id) }
  scope :with_login, lambda { where("COALESCE(username, '') != ''") }

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

  def email_address
    email
  end


  def contact_info
    "#{full_name_with_title}\n#{job_title}\n#{email}\n#{phone}"
  end

  def full_address
    if address_more.present? && address_more != address
      "#{address}\n#{address_more}"
    else
      address
    end
  end

  def from_ungc?
    organization&.name == DEFAULTS[:ungc_organization_name]
  end

  def from_organization?
    organization_id? && !from_ungc?
  end

  def from_network?
    (local_network_id? || local_network.present?)
  end

  def belongs_to_network?(network)
    from_network? && local_network == network
  end

  def from_regional_center?
    from_network? && local_network.regional_center?
  end

  def from_network_guest?
    organization&.name == DEFAULTS[:local_network_guest_name]
  end

  def from_rejected_organization?
    organization&.rejected?
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
      args.fetch(:local_network_name) { local_network&.name }
    else
      args.fetch(:organization_name) { organization&.name }
    end
  end

  def country_name
    country&.name
  end

  def user_type
    return TYPE_UNGC if from_ungc?
    return TYPE_REGIONAL if from_regional_center?
    return TYPE_NETWORK if from_network?
    return TYPE_NETWORK_GUEST if from_network_guest?
    return TYPE_ORGANIZATION if from_organization?
  end

  def is?(role)
    ContactsRole.where(contact_id: self.id, role_id: role).exists?
  end

  def can_login?
    has_login_role?
  end

  def has_login_role?
    Role.login_roles.any? { |r| is?(r) }
  end

  def needs_to_update_contact_info?
    if from_organization?
      last_update < (Date.today - Contact::MONTHS_SINCE_LOGIN.months)
    end
  end

  def needs_to_change_password?
    return true if last_password_changed_at.nil?

    last_password_changed_at < STRONG_PASSWORD_POLICY_DATE.beginning_of_day
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

  # TODO remove once encrypted_passwords are moved over to bcrypt
  def valid_password?(password)
    begin
      super(password)
    rescue BCrypt::Errors::InvalidHash
      # encrypted_password doesn't contain a BCrypt hash
      # this is because it is still using the old SHA1 hash
      # try to authenticate the user with the old digest
      if Contact.old_password_digest(password) == encrypted_password
        # the old digest worked, set the password in hopes that this
        # contact is saved, thereby moving to BCrypt.
        logger.info "User #{email} is using the old password hashing method, updating attribute."
        self.password = password
        true
      else
        false
      end
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
      # The concept of User and Contacts are mixed in this model
      # A contact as written may be a collection of information about a person
      # or it may (also) be a user of the system who can login.

      # if the contact doesn't have a username, they are not able to login and
      # therefore password is not required
      return false unless username.present?

      # contacts with a username are required to have a valid password
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

    def mark_passwords_as_updated
      if self.changed.include?("encrypted_password")
        self.last_password_changed_at = Time.current
      end
    end

    # TODO remove once encrypted_passwords are moved over to bcrypt
    def self.old_password_digest(password)
      Digest::SHA1.hexdigest("#{password}--UnGc--")
    end

    def last_update
      previous_sign_in_at = previous_changes.fetch(:last_sign_in_at, []).first
      previous_sign_in_at || last_sign_in_at || updated_at
    end

end
