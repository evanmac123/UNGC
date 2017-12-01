module Crm
  class LocalNetworkSync

    def initialize(crm = Crm::Salesforce.new)
      @crm = crm
      @adapter = Crm::LocalNetworkAdapter.new
    end

    def create(local_network)
      @crm.log("creating LocalNetwork #{local_network.name} (#{local_network.id})")
      upsert(local_network)
    end

    def update(local_network, fields)
      @crm.log("updating LocalNetwork #{local_network.name}, (#{local_network.id}) #{fields}")
      upsert(local_network)
    end

    def destroy(local_network_id)
      crm_network = @crm.find_local_network(local_network_id)
      if crm_network.present?
        attrs = { "IsDeleted" => true, Id: crm_network.Id }
        @crm.update(crm_field_name, crm_network.Id, attrs)
      end
    end

    def self.should_sync?(_)
      true
    end

    def self.crm_field_name
      SObjectName
    end

    private

    SObjectName = "Local_Network__c".freeze

    def crm_field_name
      self.class.crm_field_name
    end

    def upsert(local_network)
      crm_network = @crm.find_local_network(local_network.id)

      attrs = @adapter.to_crm_params(local_network)
      if crm_network.nil?
        @crm.create(crm_field_name, attrs)
      else
        @crm.update(crm_field_name, crm_network.Id, attrs)
        crm_network.Id
      end
    end

  end
end
