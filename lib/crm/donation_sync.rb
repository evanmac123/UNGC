module Crm
  class DonationSync
    SObjectName = 'FGC_Paypal_Payments__c'.freeze
    IdField = 'Paypal_Transaction_ID__c'.freeze
    MetadataField = 'Metadata__c'.freeze

    def initialize(crm = Crm::Salesforce.new)
      @crm = crm
    end

    def upsert(donation)
      @crm.log "creating donation #{donation.id}"

      payment = @crm.find(SObjectName, donation.id.to_s, IdField)

      adapter = Crm::Adapters::Donation.new(donation)

      params = adapter.transformed_crm_params(:create)
      if payment.present?
        @crm.update(SObjectName, payment.Id, params)
      else
        @crm.create(SObjectName, params)
      end
    end

  end
end
