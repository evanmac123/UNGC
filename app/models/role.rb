# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  old_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#  initiative_id :integer
#  description   :string(255)
#  position      :integer
#

class Role < ActiveRecord::Base
  validates_presence_of :name, :description
  has_and_belongs_to_many :contacts, :join_table => "contacts_roles"
  belongs_to :initiative
  default_scope { order('roles.position, roles.initiative_id, roles.name') }

  before_update :check_for_filtered_name_change

  FILTERS = {
    :ceo                       => 'Highest Level Executive',
    :contact_point             => 'Contact Point',
    :financial_contact         => 'Financial Contact',
    :general_contact           => 'General Contact',
    :network_focal_point       => 'Network Contact Person',
    :network_guest_user        => 'Local Network Guest',
    :network_regional_manager  => 'Local Network Manager',
    :network_report_recipient  => 'Network Report Recipient',
    :network_representative    => 'Network Representative',
    :survey_contact            => 'Annual Survey Contact',
    :website_editor            => 'Website Editor',
    :participant_manager       => 'Participant Relationship Manager'
  }

  def self.visible_to(user, current_contact=nil)
    case user.user_type
    when Contact::TYPE_ORGANIZATION
      roles_ids = [Role.contact_point].collect(&:id)

      # give option to check Highlest Level Executive if no CEO has been assigned
      if user.is?(Role.ceo) || user.organization.contacts.ceos.count <= 0
        roles_ids << Role.ceo.id
      end

      # only editable by Global Compact staff
      if current_contact && current_contact.from_ungc?
        roles_ids << Role.ceo.id
        roles_ids << Role.survey_contact.id
      end

      # only business organizations have a financial contact
      roles_ids << Role.financial_contact.id if user.organization.business_entity?

      # if the organization signed an initiative, then add the initiative's role, if available
      roles_ids << Role.where("initiative_id in (?)", user.organization.initiative_ids).all.collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_UNGC
      roles_ids = [Role.ceo,
                   Role.contact_point,
                   Role.network_regional_manager,
                   Role.website_editor,
                   Role.participant_manager].collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_NETWORK
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient, Role.general_contact].collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_NETWORK_GUEST
      roles_ids = [Role.network_guest_user].collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_REGIONAL
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient, Role.general_contact].collect(&:id)
      where('id in (?)', roles_ids.flatten)
    else
      none
    end
  end

  # Local Network roles

  scope :network_focal_points, -> { where(name: FILTERS[:network_focal_point]) }
  def self.network_focal_point
    network_focal_points.first
  end

  scope :network_representatives, -> { where(name: FILTERS[:network_representative]) }
  def self.network_representative
    network_representatives.first
  end

  scope :network_report_recipients, -> { where(name: FILTERS[:network_report_recipient]) }
  def self.network_report_recipient
    network_report_recipients.first
  end

  scope :network_guest_users, -> { where(name: FILTERS[:network_guest_user]) }
  def self.network_guest_user
    network_guest_users.first
  end

  def self.network_contacts
    [Role.network_representative, Role.network_focal_point, Role.network_report_recipient]
  end

  # Participant organization roles

  scope :ceos, -> { where(name: FILTERS[:ceo]) }
  def self.ceo
    ceos.first
  end

  scope :contact_points, -> { where(name: FILTERS[:contact_point]) }
  def self.contact_point
    contact_points.first
  end

  scope :general_contacts, -> { where(name: FILTERS[:general_contact]) }
  def self.general_contact
    general_contacts.first
  end

  scope :financial_contacts, -> { where(name: FILTERS[:financial_contact]) }
  def self.financial_contact
    financial_contacts.first
  end

  scope :survey_contacts, -> { where(name: FILTERS[:survey_contact]) }
  def self.survey_contact
    survey_contacts.first
  end

  # Global Compact staff roles

  scope :website_editors, -> { where(name: FILTERS[:website_editor]) }
  def self.website_editor
    website_editors.first
  end

  scope :network_regional_managers, -> { where(name: FILTERS[:network_regional_manager]) }
  def self.network_regional_manager
    network_regional_managers.first
  end

  scope :participant_managers, -> { where(name: FILTERS[:participant_manager]) }
  def self.participant_manager
    participant_managers.first
  end

  def self.login_roles
    [Role.contact_point, Role.network_report_recipient, Role.network_focal_point, Role.network_guest_user]
  end

  private

  def check_for_filtered_name_change
    if name_changed? && FILTERS.values.include?(name_was)
      errors.add :base, "You cannot change that Role name."
      return false
    end
  end

end
