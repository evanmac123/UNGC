# frozen_string_literal: true

module Crm
  module Adapters
    class LocalNetwork < Crm::Adapters::Base

      def to_crm_params(transform_action)
        {
            "External_ID__c" => self.class.convert_id(model.id),
            "Name" => text(model.name, 80),
            "Country__c" => model.country.try!(:name),
            "Business_Model__c" => business_model,
            "To_be_Invoiced_by__c" => invoiced_by,
        }
      end

      def self.convert_id(rails_id)
        id = rails_id.to_s.rjust(3, '0')
        "LN-#{id}"
      end

      private

      def business_model
        case model.business_model
          when "revenue_sharing" then "Revenue Sharing"
          when "global_local" then "Global-Local"
          when "not_yet_decided" then "Not yet decided"
          when nil then "N/A"
          else
            raise "Unexpected business model \"#{model.business_model}\""
        end
      end

      def invoiced_by
        case model.invoice_managed_by
          when "gco" then "GCO"
          when "local_network" then "Local Network"
          when "on_hold" then "On hold"
          when "global_or_local" then "1B+ by GCO & <1B by LN"
          when nil then nil
          else
            raise "Unexpected value for invoiced_managed_by \"#{model.invoice_managed_by}\""
        end
      end

    end
  end
end
