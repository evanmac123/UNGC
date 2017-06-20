class Crm::Owner < ActiveRecord::Base
  belongs_to :contact

  DEFAULT_SALESFORCE_OWNER_ID = '005A0000004KjLy'.freeze

  PARTICIPANT_MANAGER_SUBS = {
    13224 => 40613,   # Meng Asigned to Naoko
    226681 => 18334,  # GC Africa assigned to Gordana
  }.freeze

  # The Salesforce User ID for the given contact_id. Defaults to a known
  # account if one is not found.
  def self.owner_id(contact_id)
    # Some participant managers are substituted for others.
    # For example the PM for GC Africa is replaced by Gordana.
    # Make that substitution here, defaulting to the contact
    sub_id = PARTICIPANT_MANAGER_SUBS.fetch(contact_id, contact_id)

    # Make the translation from the UNGC Contact ID to the salesforce User ID.
    # If one is not found, use the default "SForce" account.
    owner = self.find_by(contact_id, sub_id)
    owner.try!(:crm_id) || DEFAULT_SALESFORCE_OWNER_ID
  end

  def name
    contact.try!(:name)
  end

end
