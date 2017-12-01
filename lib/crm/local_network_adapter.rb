module Crm
  class LocalNetworkAdapter < AdapterBase

    def to_crm_params(local_network)
      {
        "External_ID__c" => self.class.convert_id(local_network.id),
        "Name" => text(local_network.name, 80),
        "Country__c" => local_network.country.try!(:name),
        "Business_Model__c" => business_model(local_network),
        "To_be_Invoiced_by__c" => invoiced_by(local_network),
      }.transform_values do |value|
        Crm::Salesforce.coerce(value)
      end
    end

    def self.convert_id(local_network_id)
      id = local_network_id.to_s.rjust(3, '0')
      "LN-#{id}"
    end

    private

    def business_model(local_network)
      case local_network.business_model
      when "revenue_sharing" then "Revenue Sharing"
      when "global_local" then "Global-Local"
      when "not_yet_decided" then "Not yet decided"
      when nil then "N/A"
      else
        raise "Unexpected business model \"#{local_network.business_model}\""
      end
    end

    def invoiced_by(local_network)
      case local_network.invoice_managed_by
      when "gco" then "GCO"
      when "local_network" then "Local Network"
      when "on_hold" then "On hold"
      when "global_or_local" then "1B+ by GCO & <1B by LN"
      when nil then nil
      else
        raise "Unexpected value for invoiced_managed_by \"#{local_network.invoice_managed_by}\""
      end
    end

  end
end
