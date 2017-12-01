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

      if sf_contact.nil?
        params['npe01__PreferredPhone__c'] = "Work"
        create_contact(params)
      else
        params['npe01__PreferredPhone__c'] = sf_contact.npe01__PreferredPhone__c || "Work"
        update_contact(sf_contact.Id, params)
        sf_contact.Id
      end
    end

    private

    def create_contact(params)
      @crm.create('Contact', params)
    rescue Faraday::ClientError => e
      duplicate_pattern = /duplicate value found: .* on record with id: (\w+)/

      matches = duplicate_pattern.match(e.to_s)
      if matches
        # this is a concurrency error, the record has been created since we checked
        # try again as an update
        salesforce_id = matches[1]
        update_contact(salesforce_id, params)
      else
        # Not sure what this is, raise it again
        raise e
      end
    end

    def update_contact(salesforce_id, params)
      @crm.update('Contact', salesforce_id, params)
    end

    def lookup_account_id(ungc_contact)
      if ungc_contact.organization_id.present?
        @crm.find_account(ungc_contact.organization_id)&.Id
      end
    end

  end
end
