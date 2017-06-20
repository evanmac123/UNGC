module Crm
  class ContactAdapter

    def to_crm_params(contact)
      {
        'UNGC_Contact_ID__c' => contact.id,     # Number(18,0)
        'Salutation' => contact.prefix,         # Picklist
        'FirstName' => contact.first_name,      # Text(40)
        'LastName' => contact.last_name,        # Text(80)
        'Title' => contact.job_title,           # Text(128)
        'OwnerId' => find_owner(contact),       # Lookup(User)
        'Email' => contact.email,               # Email
        'Phone' => contact.phone,               # Phone
        'MobilePhone' => contact.mobile,        # Phone
        'npe01__PreferredPhone__c' => "Work",   # Picklist
        'Fax' => contact.fax,                   # Fax
        'Role__c' => contact.roles
          .map(&:name)
          .join(";"),                           # Picklist (Multi-Select)

        # These are combined into an Address type
        'MailingStreet' => contact.full_address,
        'MailingCity' => contact.city,
        'MailingState' => contact.state,
        'MailingPostalCode' => contact.postal_code.try!(:truncate, 20),
        'MailingCountry' => contact.country.name,
      }.transform_values do |value|
        Crm::Salesforce.coerce(value)
      end
    end

    private

    def find_owner(contact)
      manager_id = contact.organization.try!(:participant_manager_id)
      Crm::Owner.owner_id(manager_id)
    end

  end
end
