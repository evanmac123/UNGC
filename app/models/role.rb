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
  default_scope :order => 'roles.position, roles.initiative_id, roles.name'

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
    :website_editor            => 'Website Editor',
    :participant_manager       => 'Participant Relationship Manager'
  }

  def self.visible_to(user, current_contact=nil)
    if user.user_type == Contact::TYPE_ORGANIZATION
      roles_ids = [Role.contact_point].collect(&:id)
      # give option to check Highlest Level Executive if no CEO has been assigned
      roles_ids << Role.ceo.id if user.is?(Role.ceo) || user.organization.contacts.ceos.count <= 0
      if current_contact && current_contact.from_ungc?
        roles_ids << Role.ceo.id
      end
      # only business organizations have a financial contact
      roles_ids << Role.financial_contact.id if user.organization.business_entity?

      # if the organization signed an initiative, then add the initiative's role, if available
      roles_ids << Role.where("initiative_id in (?)", user.organization.initiative_ids).all.collect(&:id)
      where('id in (?)', roles_ids.flatten)
    elsif user.user_type == Contact::TYPE_UNGC
      roles_ids = [Role.ceo,
                   Role.contact_point,
                   Role.network_regional_manager,
                   Role.website_editor,
                   Role.participant_manager].collect(&:id)
      where('id in (?)', roles_ids.flatten)
    elsif user.user_type == Contact::TYPE_NETWORK
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient, Role.general_contact].collect(&:id)
      where('id in (?)', roles_ids.flatten)
    elsif user.user_type == Contact::TYPE_NETWORK_GUEST
       roles_ids = [Role.network_guest_user].collect(&:id)
       where('id in (?)', roles_ids.flatten)
    else
      {}
    end
  end

  # Local Network roles

  def self.network_focal_point
    find :first, :conditions => { :name => FILTERS[:network_focal_point] }
  end

  def self.network_representative
    find :first, :conditions => { :name => FILTERS[:network_representative] }
  end

  def self.network_report_recipient
    find :first, :conditions => { :name => FILTERS[:network_report_recipient] }
  end

  def self.network_guest_user
    find :first, :conditions => { :name => FILTERS[:network_guest_user] }
  end

  def self.network_contacts
    [Role.network_representative, Role.network_focal_point, Role.network_report_recipient]
  end

  # Participant organization roles

  def self.ceo
    find :first, :conditions => { :name => FILTERS[:ceo] }
  end

  def self.contact_point
    find :first, :conditions => { :name => FILTERS[:contact_point] }
  end

  def self.general_contact
    find :first, :conditions => { :name => FILTERS[:general_contact] }
  end

  def self.financial_contact
    find :first, :conditions => { :name => FILTERS[:financial_contact] }
  end

  # Global Compact staff roles

  def self.website_editor
    find :first, :conditions => { :name => FILTERS[:website_editor] }
  end

  def self.network_regional_manager
    find :first, :conditions => { :name => FILTERS[:network_regional_manager] }
  end

  def self.participant_manager
    find :first, :conditions => { :name => FILTERS[:participant_manager] }
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
