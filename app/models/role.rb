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
  has_many :contacts_roles, inverse_of: :role
  has_many :contacts, through: :contacts_roles
  belongs_to :initiative
  default_scope { order('roles.position, roles.initiative_id, roles.name') }

  before_update :check_for_filtered_name_change

  validates_length_of :description, maximum: 255

  FILTERS = {
    ceo: 'Highest Level Executive',
    contact_point: 'Contact Point',
    financial_contact: 'Financial Contact',
    general_contact: 'General Contact',
    network_focal_point: 'Network Contact Person',
    network_executive_director: 'Network Executive Director',
    network_board_chair: 'Local Network Board Chair',
    network_guest_user: 'Local Network Guest',
    network_regional_manager: 'Local Network Manager',
    network_report_recipient: 'Network Report Recipient',
    survey_contact: 'Annual Survey Contact',
    website_editor: 'Website Editor',
    participant_manager: 'Participant Relationship Manager',
    integrity_team_member: 'Integrity Team Member',
    integrity_manager: 'Integrity Manager',
    ceo_water_mandate: 'CEO Water Mandate',
    caring_for_climate: 'Caring for Climate',
    action_platform_manager: 'Action Platform Manager',
    academy_manager: 'Academy Manager',
    academy_local_network_representative: "Academy Local Network Representative",
  }

  def self.visible_to(user, current_contact = nil)
    case user.user_type
      when Contact::TYPE_ORGANIZATION
        role_ids = *contact_point.id

        # give option to check Highlest Level Executive if no CEO has been assigned
        role_ids = [*role_ids, ceo] if user.is?(ceo) || !user.organization.contacts.ceos.exists?

        # only editable by Global Compact staff
        role_ids = [*role_ids, *[ceo, survey_contact]] if current_contact&.from_ungc?

        # only business organizations have a financial contact
        role_ids = [*role_ids, financial_contact.id] if user.organization.business_entity?

        # if the organization signed an initiative, then add the initiative's role, if available
        role_ids << where(initiative_id: user.organization.initiative_ids).pluck(:id)

        where(id: role_ids)
      when Contact::TYPE_UNGC
        where(id: type_contact_ungc_roles)
      when Contact::TYPE_NETWORK
        where(id: type_contact_network_roles)
      when Contact::TYPE_NETWORK_GUEST
        where(id: network_guest_user)
      when Contact::TYPE_REGIONAL
        where(id: type_contact_network_roles)
      else
        none
    end
  end

  def self.network_roles_public
    Rails.cache.fetch(role_cache_key(:network_roles_public)) do
      [
          network_focal_point,
          network_executive_director,
      ]
    end
  end

  def self.type_contact_ungc_roles
    Rails.cache.fetch(role_cache_key(:type_contact_ungc_roles)) do
      [
        ceo,
        contact_point,
        network_regional_manager,
        website_editor,
        integrity_team_member,
        integrity_manager,
        participant_manager,
        action_platform_manager,
        academy_manager,
      ]
    end
  end

  def self.type_contact_network_roles
    Rails.cache.fetch(role_cache_key(:type_contact_network_roles)) do
      [
        network_executive_director,
        network_board_chair,
        network_focal_point,
        network_report_recipient,
        general_contact,
        academy_local_network_representative,
      ]
    end
  end

  # Local Network roles

  def self.network_executive_director
    Rails.cache.fetch(role_cache_key(:network_executive_director)) { find_by(name: FILTERS[:network_executive_director]) }
  end

  def self.network_board_chair
    Rails.cache.fetch(role_cache_key(:network_board_chair)) { find_by(name: FILTERS[:network_board_chair]) }
  end

  def self.network_focal_point
    Rails.cache.fetch(role_cache_key(:network_focal_point)) { find_by(name: FILTERS[:network_focal_point]) }
  end

  def self.network_report_recipient
    Rails.cache.fetch(role_cache_key(:network_report_recipient)) { find_by(name: FILTERS[:network_report_recipient]) }
  end

  def self.network_guest_user
    Rails.cache.fetch(role_cache_key(:network_guest_user)) { find_by(name: FILTERS[:network_guest_user]) }
  end

  def self.network_contacts
    Rails.cache.fetch(:network_contacts) do
      [
          network_focal_point,
          network_report_recipient,
          network_executive_director,
          network_board_chair,
      ]
    end
  end

  # Participant organization roles

  def self.ceo
    @_ceo ||= find_by(name: FILTERS[:ceo])
  end

  def self.contact_point
    @_contact_point ||= find_by(name: FILTERS[:contact_point])
  end

  def self.general_contact
    Rails.cache.fetch(role_cache_key(:general_contact)) { find_by(name: FILTERS[:general_contact]) }
  end

  def self.financial_contact
    Rails.cache.fetch(role_cache_key(:financial_contact)) { find_by(name: FILTERS[:financial_contact]) }
  end

  def self.survey_contact
    Rails.cache.fetch(role_cache_key(:survey_contact)) { find_by(name: FILTERS[:survey_contact]) }
  end

  # Global Compact staff roles

  def self.website_editor
    Rails.cache.fetch(role_cache_key(:website_editor)) { find_by(name: FILTERS[:website_editor]) }
  end

  def self.integrity_team_member
    Rails.cache.fetch(role_cache_key(:integrity_team_member)) { find_by(name: FILTERS[:integrity_team_member]) }
  end

  def self.integrity_manager
    Rails.cache.fetch(role_cache_key(:integrity_manager)) { find_by(name: FILTERS[:integrity_manager]) }
  end

  def self.network_regional_manager
    Rails.cache.fetch(role_cache_key(:network_regional_manager)) { find_by(name: FILTERS[:network_regional_manager]) }
  end

  def self.participant_manager
    Rails.cache.fetch(role_cache_key(:participant_manager)) { find_by(name: FILTERS[:participant_manager]) }
  end

  def self.ceo_water_mandate
    Rails.cache.fetch(role_cache_key(:ceo_water_mandate)) { find_by(name: FILTERS[:ceo_water_mandate]) }
  end

  def self.caring_for_climate
    Rails.cache.fetch(role_cache_key(:caring_for_climate)) { find_by(name: FILTERS[:caring_for_climate]) }
  end

  def self.action_platform_manager
    Rails.cache.fetch(role_cache_key(:action_platform_manager)) { find_by(name: FILTERS[:action_platform_manager]) }
  end

  def self.academy_manager
    Rails.cache.fetch(role_cache_key(:academy_manager)) { find_by(name: FILTERS[:academy_manager]) }
  end

  def self.academy_local_network_representative
    Rails.cache.fetch(role_cache_key(:academy_local_network_representative)) { find_by(name: FILTERS[:academy_local_network_representative]) }
  end

  def self.login_roles
    Rails.cache.fetch(:login_roles) do
      [
        contact_point,
        network_report_recipient,
        network_executive_director,
        network_board_chair,
        network_focal_point,
        network_guest_user,
        general_contact,
      ]
    end
  end

  scope :filtered, ->(*keys) {
    names = Array.wrap(keys).map do |filter|
      FILTERS[filter]
    end
    where(name: names)
  }

  def self.role_cache_key(cache_key)
    "role-model/#{cache_key}/"
  end

  private

  def check_for_filtered_name_change
    if name_changed? && FILTERS.values.include?(name_was)
      errors.add :base, "You cannot change that Role name."
      return false
    end
  end
end
