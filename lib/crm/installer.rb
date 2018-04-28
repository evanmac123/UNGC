# frozen_string_literal: true

module Crm
  class Installer

    def initialize(crm_client)
      @client = crm_client
    end

    def create_push_topics
      fields = [
        "Id",
        "AccountId",
        "CampaignId",
        "Invoice_Code__c",
        "Recognition_Amount__c",
        "Amount",
        "StageName",
        "CloseDate",
        "Payment_type__c",
        "IsDeleted",
        "CreatedDate",
        "LastModifiedDate"
      ].join(", ")

      attrs = {
        ApiVersion: @client.options[:api_version],
        Name: "OpportunityUpdates",
        Description: "Opportunity updates",
        NotifyForFields: "All",
        Query: "Select #{fields} from Opportunity Where AccountId != null"
      }

      topics = @client.query("SELECT Id, Name FROM PushTopic WHERE Name='OpportunityUpdates'")
      if topics.count == 0
        @client.create!("PushTopic", attrs)
      end
    end

  end
end
