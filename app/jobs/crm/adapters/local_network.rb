# frozen_string_literal: true

module Crm
  module Adapters
    class LocalNetwork < Crm::Adapters::Base

      def to_crm_params(transform_action)
        base = {
            Crm::LocalNetworkSyncJob::SUngcIdName => self.class.convert_id(model.id),
            "Type" => salesforce_type,
            "Name" => model.name,
            "State__c" => I18n.t("local_network.states.#{model.state}"),
            "Join_Date__c" => model.sg_local_network_launch_date, # Date
            "JoinYear__c" => model.sg_local_network_launch_date&.year, # Number(4, 0)
            "Website" => model.url,
            "Region__c" => model.countries.first&.region,
            "OwnerId" => Crm::Owner::SALESFORCE_OWNER_ID,
            "Business_Model_LN__c" => (model.business_model ? I18n.t("local_network.business_model.#{model.business_model}") : "N/A"),
            "To_Be_Invoiced_By_LN__c" => (I18n.t("local_network.invoice_managed_by.#{model.invoice_managed_by}") if model.invoice_managed_by),
        }

        if transform_action == :create
          base['RecordTypeId'] = Crm::LocalNetworkSyncJob::RecordTypeId
          base['Sector__c'] = 'Local_Network'
          base['External_ID__c'] = self.class.convert_id(model.id)
        end

        base
      end

      def self.convert_id(rails_id)
        "LN-#{rails_id}"
      end

      def salesforce_type
        model.regional_center? ? 'UNGC Regional Center' : 'UNGC Local Network'
      end
    end
  end
end
