# frozen_string_literal: true

module Crm
  module Adapters
    class LocalNetwork < Crm::Adapters::Base

      def build_crm_payload
        column(Crm::LocalNetworkSyncJob::SUngcIdName, :id) { |network| self.class.convert_id(network.id) }
        column('OwnerId', :id) { Crm::Owner::SALESFORCE_OWNER_ID }
        column('RecordTypeId', :id) { Crm::LocalNetworkSyncJob::RecordTypeId }
        column('Sector__c', :id) { 'Local_Network' }

        column('Type', :regional_center) { |network| network.regional_center? ? 'UNGC Regional Center' : 'UNGC Local Network' }
        column('Name', :name)
        column('State__c', :name) { |network| I18n.t("local_network.states.#{network.state}") }
        column('Join_Date__c', :sg_local_network_launch_date)
        column('JoinYear__c', :sg_local_network_launch_date) { |network| network.sg_local_network_launch_date&.year}
        column('Website', :url)
        column('Region__c', :country_id) { |network| network.countries.first&.region}
        column('Business_Model_LN__c', :business_model) { |network| network.business_model ? I18n.t("local_network.business_model.#{network.business_model}") : "N/A"}
        column('To_Be_Invoiced_By_LN__c', :invoice_managed_by) { |network| I18n.t("local_network.invoice_managed_by.#{network.invoice_managed_by}") if network.invoice_managed_by }
      end

      def self.convert_id(rails_id)
        "LN-#{rails_id}"
      end
    end
  end
end
