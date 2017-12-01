module Crm
  class OrganizationSync

    def initialize(crm = Crm::Salesforce.new)
      @crm = crm
      @organization_adapter = Crm::OrganizationAdapter.new
    end

    def create(organization)
      @crm.log "creating organization #{organization.name} (#{organization.id})"
      account_id = upsert_org(organization)
      upsert_contacts(organization, account_id)
      account_id
    end

    def update(organization, changed)
      @crm.log "updating organization #{organization.name} (#{organization.id})"
      account_id = upsert_org(organization, changed)
      upsert_contacts(organization, account_id)
      account_id
    end

    def destroy(organization_id)
      account = @crm.find_account(organization_id)
      if account.present?
        @crm.destroy('Account', account.Id)
      end
    end

    def self.should_sync?(organization)
      organization.sector_id.present? && organization.organization_type_id.present?
    end

    private

    def upsert_org(organization, changed = [])
      account = @crm.find_account(organization.id)

      account_id = if account.nil?
        params = @organization_adapter.to_crm_params(organization)
        @crm.create('Account', params)
      else
        params = @organization_adapter.to_crm_params(organization, changed)
        @crm.update('Account', account.Id, params)
        account.Id
      end

      account_id
    end

    def upsert_contacts(organization, account_id)
      contact_sync = Crm::ContactSync.new(@crm)

      organization.contacts.
        includes(:roles, :country, organization: [participant_manager: [:crm_owner]]).
        each { |c| contact_sync.upsert(c, account_id: account_id) }
    end

  end
end
