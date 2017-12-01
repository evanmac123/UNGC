module Crm
  class ContactAdapter < AdapterBase

    def to_crm_params(contact)
      {
        'UNGC_Contact_ID__c' => number(contact.id),
        'Salutation' => picklist(contact.prefix),
        'FirstName' => text(contact.first_name, 40),
        'LastName' => text(contact.last_name, 80),
        'Title' => text(contact.job_title, 128),
        'OwnerId' => find_owner(contact),
        'Email' => email(contact.email),
        'Phone' => phone(contact.phone),
        'MobilePhone' => phone(contact.mobile),
        'npe01__PreferredPhone__c' => picklist("Work"),
        'Fax' => fax(contact.fax),
        'Role__c' => picklist(contact.roles.pluck(:name)),
        'MailingStreet' => text(contact.full_address),
        'MailingCity' => text(contact.city, 40),
        'MailingState' => text(contact.state),
        'MailingPostalCode' => postal_code(contact.postal_code),
        'MailingCountry' => text(contact.country.name),
      }
    end

    private

    def find_owner(contact)
      owner_id = contact.organization.
        try!(:participant_manager).
        try!(:crm_owner).
        try!(:crm_id)
      owner_id || Crm::Owner::DEFAULT_OWNER_ID
    end

  end
end
