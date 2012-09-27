# == Schema Information
#
# Table name: contacts
#
#  id                        :integer(4)      not null, primary key
#  old_id                    :integer(4)
#  first_name                :string(255)
#  middle_name               :string(255)
#  last_name                 :string(255)
#  prefix                    :string(255)
#  job_title                 :string(255)
#  email                     :string(255)
#  phone                     :string(255)
#  mobile                    :string(255)
#  fax                       :string(255)
#  organization_id           :integer(4)
#  address                   :string(255)
#  city                      :string(255)
#  state                     :string(255)
#  postal_code               :string(255)
#  country_id                :integer(4)
#  login                     :string(255)
#  address_more              :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token_expires_at :datetime
#  remember_token            :string(255)
#  local_network_id          :integer(4)
#  hashed_password           :string(255)
#  password                  :string(255)
#  reset_password_token      :string(255)
#  last_login_at             :datetime
#

require 'digest/sha1'

class Contact < ActiveRecord::Base
  include VisibleTo
  include Authentication
  include Authentication::ByCookieToken

  TYPE_UNGC = :ungc
  TYPE_ORGANIZATION = :organization
  TYPE_NETWORK = :network
  TYPE_NETWORK_GUEST = :network_guest

  # if they haven't logged in then we redirect them to their edit page to confirm their contact information
  MONTHS_SINCE_LOGIN = 6

  validates_presence_of :prefix, :first_name, :last_name, :job_title, :email, :phone, :address, :city, :country_id
  validates_presence_of :login, :if => :can_login?
  validates_presence_of :password, :unless => Proc.new { |contact| contact.login.blank? }
  validates_uniqueness_of :login, :allow_nil => true, :case_sensitive => false, :allow_blank => true, :message => "with the same username already exists"
  validates_uniqueness_of :email, :on => :create
  validates_format_of   :email,
                        :with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/,
                        :message => "is not a valid email address"
  belongs_to :country
  belongs_to :organization
  belongs_to :local_network
  has_and_belongs_to_many :roles, :join_table => "contacts_roles"

  default_scope :order => 'contacts.first_name'

  # TODO LATER: remove plain text password at some point - attr_accessor :password
  before_save :encrypt_password

  before_destroy :keep_at_least_one_ceo
  before_destroy :keep_at_least_one_contact_point

  before_update  :do_not_allow_last_contact_point_to_uncheck_role
  before_update  :do_not_allow_last_ceo_to_uncheck_role

  # used for checkbox in sign up form
  # /app/views/signup/step5.html.haml
  attr_accessor :foundation_contact

  named_scope :for_mail_merge, lambda { |cop_states|
   {
    :include => :organization,
    :select => "contacts.*,
                org_country.name AS organization_country,
                o.joined_on,
                t.name AS organization_type_name,
                o.cop_state,
                s.name as sector_name,
                o.employees,
                o.is_ft_500,
                CASE country.region
                  WHEN 'africa'      THEN 'Africa'
                  WHEN 'americas'    THEN 'Americas'
                  WHEN 'asia'        THEN 'Asia'
                  WHEN 'australasia' THEN 'Australasia'
                  WHEN 'europe'      THEN 'Europe'
                  WHEN 'mena'        THEN 'MENA'
                END AS region_name,
                r.name as role_name,
                country.name AS country_name",

    :joins => "JOIN organizations o ON contacts.organization_id = o.id
               JOIN countries country ON contacts.country_id = country.id
               JOIN countries org_country ON o.country_id = org_country.id
               JOIN organization_types t ON o.organization_type_id = t.id
               JOIN sectors s ON o.sector_id = s.id
               LEFT OUTER JOIN contacts_roles ON contacts_roles.contact_id = contacts.id
               RIGHT OUTER JOIN roles r ON r.id = contacts_roles.role_id",

    :conditions => ["o.cop_state IN (?) AND
                     o.participant = 1 AND
                     t.name NOT IN ('Media Organization', 'GC Networks', 'Mailing List') AND
                     contacts_roles.role_id IN (?)", cop_states, [Role.ceo, Role.contact_point]]
    }
  }

   named_scope :for_local_network, {
     :include    => [:roles, {:organization => [:sector, :country, :organization_type]}, :country],
     :conditions => ["contacts_roles.role_id IN (?)", [Role.ceo, Role.contact_point]]
   }

  named_scope :participants_only, { :conditions => ["organizations.participant = ?", true] }

  named_scope :financial_contacts, lambda {
    contact_point_id = Role.financial_contact.try(:id)
    {
      :include    => :roles,
      :conditions => ["contacts_roles.role_id = ?", contact_point_id]
    }
  }

  named_scope :contact_points, lambda {
    contact_point_id = Role.contact_point.try(:id)
    {
      :include    => :roles,
      :conditions => ["contacts_roles.role_id = ?", contact_point_id]
    }
  }

  named_scope :ceos, lambda {
    ceo_id = Role.ceo.try(:id)
    {
      :include    => :roles,
      :conditions => ["contacts_roles.role_id = ?", ceo_id]
    }
  }

  named_scope :network_roles, lambda {
    roles = []
    roles << Role.network_focal_point
    roles << Role.network_representative
    roles << Role.network_report_recipient
    {
      :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", roles],
      :order      => "roles.name DESC"
    }
  }

  named_scope :network_roles_public, lambda {
    roles = []
    roles << Role.network_focal_point
    roles << Role.network_representative
    {
      :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", roles],
      :order      => "roles.name DESC"
    }
  }

  named_scope :network_contacts, lambda {
    role = Role.network_focal_point
    {
      :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", role],
      :order      => "roles.name DESC"
    }
  }

  named_scope :network_representatives, lambda {
    role = Role.network_representative
    {
      :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", role],
      :order      => "roles.name DESC"
    }
  }

  named_scope :network_report_recipients, lambda {
    role = Role.network_report_recipient
    {
      :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", role]
    }
  }

  named_scope :network_monthly_reports, lambda {
     roles = []
      roles << Role.network_report_recipient
      roles << Role.network_monthly_report
      {
        :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
        :conditions => ["contacts_roles.role_id IN (?)", roles],
        :order      => "roles.name DESC"
      }
  }

  named_scope :network_regional_managers, lambda {
    role = Role.network_regional_manager
    {
      :include    => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", role]
    }
  }

  named_scope :for_country, lambda { |country|
    {:conditions => {:country_id => country.id} }
  }

  named_scope :with_login, {:conditions => 'login IS NOT NULL'}

  define_index do
    indexes first_name, last_name, middle_name, email
    set_property :enable_star => true
    set_property :min_prefix_len => 4
  end

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
    "#{name} <#{email}>"
  end

  def contact_info
    "#{full_name_with_title}\n#{job_title}\n#{email}\n#{phone}"
  end

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase)
    (u && u.hashed_password == encrypted_password(password)) ? u : nil
  end

  def set_last_login_at
    self.update_attribute :last_login_at, Time.now
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

  def from_network_guest?
    organization_id? && organization.name == DEFAULTS[:local_network_guest_name]
  end

  def from_rejected_organization?
    organization.try(:rejected?)
  end

  def submit_grace_letter?
    self.organization.can_submit_grace_letter?
  end

  def organization_delisted_on
    self.organization.delisted_on
  end

  def organization_name
    from_network? ? local_network.try(:name) : organization.try(:name)
  end

  def country_name
    country.try(:name)
  end

  def user_type
    return TYPE_UNGC if from_ungc?
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
    return if password.blank?
    self.hashed_password = Contact.encrypted_password(password)
  end

  def refresh_reset_password_token!
    self.update_attribute :reset_password_token, Digest::SHA1.hexdigest([login, Time.now].join)
  end

  def needs_to_update_contact_info
    unless from_ungc? || from_network_guest?
      last_update = last_login_at || updated_at
      last_update < (Date.today - Contact::MONTHS_SINCE_LOGIN.months)
    end
  end

  def rejected_organization_email
    self.update_attribute :email, "rejected.#{self.email}"
  end

  def last_contact_or_ceo?(role, current_user)
    if current_user.from_organization? && !new_record?
      if role == Role.ceo
        return true if self.is?(Role.ceo) && organization.contacts.ceos.count == 1
      elsif role == Role.contact_point
        return true if self.is?(Role.contact_point) && organization.contacts.contact_points.count == 1
      end
    end
  end

  private

    def keep_at_least_one_ceo
      if self.is?(Role.ceo) && self.organization.contacts.ceos.count <= 1
        errors.add_to_base "cannot delete CEO, at least 1 CEO should be kept at all times"
        return false
      end
    end

    def keep_at_least_one_contact_point
      if self.is?(Role.contact_point) && self.organization.contacts.contact_points.count <= 1
        errors.add_to_base "cannot delete Contact Point, at least 1 Contact Point should be kept at all times"
        return false
      end
    end

    def do_not_allow_last_contact_point_to_uncheck_role
      if self.from_organization? && self.organization.participant && !self.is?(Role.contact_point) && self.organization.contacts.contact_points.count < 1
        self.roles << Role.contact_point
        errors.add_to_base "There should be at least one Contact Point"
        return false
      end
    end

    def do_not_allow_last_ceo_to_uncheck_role
      if self.from_organization? && self.organization.participant && !self.is?(Role.ceo) && self.organization.contacts.ceos.count < 1
        self.roles << Role.ceo
        errors.add_to_base "There should be at least one Highest Level Executive"
        return false
      end
    end

    def self.encrypted_password(password)
      Digest::SHA1.hexdigest("#{password}--UnGc--")
    end
end
