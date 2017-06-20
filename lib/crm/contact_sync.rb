module Crm
  class ContactSync

    def initialize(crm = Crm::Salesforce.new)
      @crm = crm
      @contact_adapter = Crm::ContactAdapter.new
    end

    def self.should_sync?(_contact)
      true
    end

    def create(ungc_contact)
      upsert(ungc_contact)
    end

    def update(ungc_contact, fields)
      upsert(ungc_contact)
    end

    def destroy(ungc_contact_id)
      contact = @crm.find_contact(ungc_contact_id)
      if contact.present?
        @crm.destroy('Contact', contact.Id)
      end
    end

    def upsert(ungc_contact, account_id: nil)
      sf_contact = @crm.find_contact(ungc_contact.id)
      params = @contact_adapter.to_crm_params(ungc_contact)

      params['AccountId'] = account_id || lookup_account_id(ungc_contact)

      contact_id = if sf_contact.nil?
                     params['npe01__PreferredPhone__c'] = "Work"
                     @crm.create('Contact', params)
                   else
                     params['npe01__PreferredPhone__c'] = sf_contact.npe01__PreferredPhone__c || "Work"
                     @crm.update('Contact', sf_contact.Id, params)
                     sf_contact.Id
                   end

      contact_id
    end

    def lookup_account_id(ungc_contact)
      if ungc_contact.organization_id.present?
        @crm.find_account(ungc_contact.organization_id).try!(:Id)
      end
    end

  end
end
