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
    :participant_manager       => 'Participant Relationship Manager',
    :integrity_team_member     => 'Integrity Team Member',
    :integrity_manager         => 'Integrity Manager',
  }

  def self.visible_to(user, current_contact=nil)
    case user.user_type
    when Contact::TYPE_ORGANIZATION
      roles_ids = [Role.contact_point].freeze.collect(&:id)

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
                   Role.participant_manager].freeze.collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_NETWORK
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient, Role.general_contact].freeze.collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_NETWORK_GUEST
      roles_ids = [Role.network_guest_user].freeze.collect(&:id)
      where('id in (?)', roles_ids.flatten)
    when Contact::TYPE_REGIONAL
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient, Role.general_contact].freeze.collect(&:id)
      where('id in (?)', roles_ids.flatten)
    else
      none
    end
  end

  # Local Network roles
  scope :contact_points, lambda { where(name: FILTERS[:contact_point]) }

  scope :network_focal_points, -> { where(name: FILTERS[:network_focal_point]) }
  def self.network_focal_point
    @_network_focal_point ||= find_by(name: FILTERS[:network_focal_point])
  end

  scope :network_representatives, -> { where(name: FILTERS[:network_representative]) }
  def self.network_representative
    @_network_representative ||= find_by(name: FILTERS[:network_representative])
  end

  scope :network_report_recipients, -> { where(name: FILTERS[:network_report_recipient]) }
  def self.network_report_recipient
    @_network_report_recipient ||= find_by(name: FILTERS[:network_report_recipient])
  end

  scope :network_guest_users, -> { where(name: FILTERS[:network_guest_user]) }
  def self.network_guest_user
    @_network_guest_user ||= find_by(name: FILTERS[:network_guest_user])
  end

  def self.network_contacts
    [Role.network_representative, Role.network_focal_point, Role.network_report_recipient]
  end

  # Participant organization roles

  scope :ceos, -> { where(name: FILTERS[:ceo]) }
  def self.ceo
    @_ceo ||= find_by(name: FILTERS[:ceo])
  end

  scope :contact_points, -> { where(name: FILTERS[:contact_point]) }
  def self.contact_point
    @_contact_point ||= find_by(name: FILTERS[:contact_point])
  end

  scope :general_contacts, -> { where(name: FILTERS[:general_contact]) }
  def self.general_contact
    @_general_contact ||= find_by(name: FILTERS[:general_contact])
  end

  scope :financial_contacts, -> { where(name: FILTERS[:financial_contact]) }
  def self.financial_contact
    @_financial_contact ||= find_by(name: FILTERS[:financial_contact])
  end

  scope :survey_contacts, -> { where(name: FILTERS[:survey_contact]) }
  def self.survey_contact
    @_survey_contact ||= find_by(name: FILTERS[:survey_contact])
  end

  # Global Compact staff roles

  scope :website_editors, -> { where(name: FILTERS[:website_editor]) }
  def self.website_editor
    @_website_editor ||= find_by(name: FILTERS[:website_editor])
  end

  def self.integrity_team_member
    @_integrity_team_member ||= find_by(name: FILTERS[:integrity_team_member])
  end

  def self.integrity_manager
    @_integrity_manager ||= find_by(name: FILTERS[:integrity_manager])
  end

  scope :network_regional_managers, -> { where(name: FILTERS[:network_regional_manager]) }
  def self.network_regional_manager
    @_network_regional_manager ||= find_by(name: FILTERS[:network_regional_manager])
  end

  scope :participant_managers, -> { where(name: FILTERS[:participant_manager]) }
  def self.participant_manager
    @_participant_manager ||= find_by(name: FILTERS[:participant_manager])
  end

  def self.login_roles
    [
        Role.contact_point,
        Role.network_report_recipient,
        Role.network_focal_point,
        Role.network_guest_user,
        Role.network_representative,
        Role.general_contact,
    ].freeze
  end

  scope :filtered, ->(*keys) {
    names = Array.wrap(keys).map do |filter|
      FILTERS[filter]
    end
    where(name: names)
  }

  private

  def check_for_filtered_name_change
    if name_changed? && FILTERS.values.include?(name_was)
      errors.add :base, "You cannot change that Role name."
      return false
    end
  end

end
