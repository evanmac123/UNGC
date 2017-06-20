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

      params = to_crm(donation)
      if payment.present?
        @crm.update(SObjectName, payment.Id, params)
      else
        @crm.create(SObjectName, params)
      end
    end

    private

    def to_crm(donation)
      {
        IdField => donation.id,
        MetadataField => {
          ungc: donation.metadata,
          stripe_response: donation.full_response,
        }.to_json
      }.transform_values do |value|
        Crm::Salesforce.coerce(value)
      end
    end

  end
end
