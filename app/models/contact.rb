# == Schema Information
#
# Table name: contacts
#
#  id               :integer(4)      not null, primary key
#  old_id           :integer(4)
#  first_name       :string(255)
#  middle_name      :string(255)
#  last_name        :string(255)
#  prefix           :string(255)
#  job_title        :string(255)
#  email            :string(255)
#  phone            :string(255)
#  mobile           :string(255)
#  fax              :string(255)
#  organization_id  :integer(4)
#  address          :string(255)
#  city             :string(255)
#  state            :string(255)
#  postal_code      :string(255)
#  country_id       :integer(4)
#  ceo              :boolean(1)
#  contact_point    :boolean(1)
#  newsletter       :boolean(1)
#  advisory_council :boolean(1)
#  login            :string(255)
#  password         :string(255)
#  address_more     :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Contact < ActiveRecord::Base
  include Authentication
  include Authentication::ByCookieToken

  validates_presence_of :first_name, :last_name
  belongs_to :organization
  belongs_to :country

  default_scope :order => 'contacts.first_name'

  def name
    [first_name, last_name].join(' ')
  end
  
  def name_with_title
    [prefix, first_name, last_name].join(' ')
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
end
