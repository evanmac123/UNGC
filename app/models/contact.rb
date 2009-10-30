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
#  ceo                       :boolean(1)
#  contact_point             :boolean(1)
#  newsletter                :boolean(1)
#  advisory_council          :boolean(1)
#  login                     :string(255)
#  password                  :string(255)
#  address_more              :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token_expires_at :datetime
#  remember_token            :string(255)
#

class Contact < ActiveRecord::Base
  include Authentication
  include Authentication::ByCookieToken

  TYPE_UNGC = :ungc
  TYPE_ORGANIZATION = :organization
  TYPE_NETWORK = :network

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :login, :allow_nil => true
  validates_presence_of :password, :unless => Proc.new { |contact| contact.login.blank? }
  belongs_to :country
  belongs_to :organization
  belongs_to :local_network
  has_and_belongs_to_many :roles, :join_table => "contacts_roles"

  default_scope :order => 'contacts.first_name'
  
  named_scope :contact_points, lambda {
    contact_point_id = Role.contact_point.try(:id)
    {
      :joins      => :roles,
      :conditions => ["contacts_roles.role_id = ?", contact_point_id]
    }
  }

  named_scope :ceos, lambda {
    ceo_id = Role.ceo.try(:id)
    {
      :joins      => :roles,
      :conditions => ["contacts_roles.role_id = ?", ceo_id]
    }
  }
  
  named_scope :network_contacts, lambda {
    roles = Role.network_contact
    {
      :joins => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", roles],
      :order => "roles.name DESC"
    }
  }
  
  named_scope :network_contacts, lambda {
    roles = Role.network_contact
    {
      :joins => :roles, # "contacts_roles on contacts.id = contacts_roles.contact_id",
      :conditions => ["contacts_roles.role_id IN (?)", roles],
      :order => "roles.name DESC"
    }
  }
  named_scope :for_country, lambda { |country|
    {:conditions => {:country_id => country.id} }
  }

  before_destroy :keep_at_least_one_contact

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

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase)
    # TODO hash the password
    (u && u.password == password) ? u : nil
  end
  
  def from_ungc?
    # TODO add a robust condition
    organization.name == 'UNGC'
  end
  
  def from_organization?
    !organization_id.nil? && !from_ungc?
  end
  
  def from_network?
    !local_network_id.nil? && !from_ungc?
  end
  
  def user_type
    return TYPE_UNGC if from_ungc?
    return TYPE_NETWORK if from_network?
    return TYPE_ORGANIZATION if from_organization?
  end
  
  private
    def keep_at_least_one_contact
      if self.organization.contacts.count <= 1
        errors.add_to_base "cannot delete contact, at least 1 contact should be kept at all times"
        return false
      end
    end
end
