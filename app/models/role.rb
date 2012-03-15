# == Schema Information
#
# Table name: roles
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  old_id        :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  initiative_id :integer(4)
#  description   :string(255)
#  position      :integer(4)
#

class Role < ActiveRecord::Base
  validates_presence_of :name, :description
  has_and_belongs_to_many :contacts, :join_table => "contacts_roles"
  belongs_to :initiative
  default_scope :order => 'roles.position, roles.initiative_id, roles.name'

  FILTERS = {
    :ceo                       => 3,
    :contact_point             => 4,
    :general_contact           => 9,
    :financial_contact         => 2,
    :website_editor            => 15,
    :network_focal_point       => 5,
    :network_representative    => 12,
    :network_report_recipient  => 13,
    :network_regional_manager  => 14,
    :network_monthly_report    => 16
  }

  named_scope :visible_to, lambda { |user, current_user = nil|
    if user.user_type == Contact::TYPE_ORGANIZATION
      roles_ids = [Role.contact_point].collect(&:id)

      # give option to check Highlest Level Executive if no CEO has been assigned
      roles_ids << Role.ceo.id if user.is?(Role.ceo) || user.organization.contacts.ceos.count <= 0

      if current_user && current_user.from_ungc?
        roles_ids << Role.ceo.id
      end

      # only business organizations have a financial contact
      roles_ids << Role.financial_contact.id if user.organization.business_entity?
      # if the organization signed an initiative, then add the initiative's role, if available
      roles_ids << Role.all(:conditions => ["initiative_id in (?)", user.organization.initiative_ids]).collect(&:id)
      { :conditions => ['id in (?)', roles_ids.flatten] }

    elsif user.user_type == Contact::TYPE_UNGC
      roles_ids = [Role.ceo, Role.contact_point, Role.network_regional_manager, Role.website_editor].collect(&:id)
      { :conditions => ['id in (?)', roles_ids.flatten] }

    elsif user.user_type == Contact::TYPE_NETWORK
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient, Role.network_monthly_report, Role.general_contact].collect(&:id)
      { :conditions => ['id in (?)', roles_ids.flatten] }
    else
      {}
    end
  }

  def self.network_contacts
    find :all, :conditions => ["old_id in (?)", [5,12,13]]
  end

  def self.network_focal_point
    find :first, :conditions => ["old_id=?", FILTERS[:network_focal_point]]
  end

  def self.network_representative
    find :first, :conditions => ["old_id=?", FILTERS[:network_representative]]
  end

  def self.network_report_recipient
    find :first, :conditions => ["old_id=?", FILTERS[:network_report_recipient]]
  end

  def self.network_regional_manager
    find :first, :conditions => ["old_id=?", FILTERS[:network_regional_manager]]
  end
  
  def self.network_monthly_report
    find :first, :conditions => ["old_id=?", FILTERS[:network_monthly_report]]
  end

  def self.ceo
    find :first, :conditions => ["old_id=?", FILTERS[:ceo]]
  end

  def self.contact_point
    find :first, :conditions => ["old_id=?", FILTERS[:contact_point]]
  end

  def self.general_contact
    find :first, :conditions => ["old_id=?", FILTERS[:general_contact]]
  end

  def self.financial_contact
    find :first, :conditions => ["old_id=?", FILTERS[:financial_contact]]
  end

  def self.website_editor
    find :first, :conditions => ["old_id=?", FILTERS[:website_editor]]
  end

  def self.login_roles
    [Role.contact_point, Role.network_report_recipient, Role.network_focal_point]
  end
end
