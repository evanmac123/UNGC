# frozen_string_literal: true

module Crm
  class Salesforce
    attr_reader :client

    def initialize(client = nil, log: false)
      @client = client || begin
        config = DEFAULTS[:salesforce]
        ::Restforce.log = log
        ::Restforce.new(
          api_version: '41.0',
          host: config.fetch(:host),
          username: config.fetch(:username),
          security_token: config.fetch(:token),
          password: config.fetch(:password),
          client_id: config.fetch(:client_id),
          client_secret: config.fetch(:client_secret)
        )
      end
    end

    def log(message)
      Rails.logger.info message
    end

    def create(type, params)
      client.create!(type, params)
    end

    def query(query)
      client.query(query)
    end

    def find(type, id_or_field, field_name = nil)
      if field_name.nil?
        client.find(type, id_or_field)
      else
        client.find(type, id_or_field, field_name)
      end
    rescue Faraday::Error::ResourceNotFound
      nil
    end

    def update(type, id, params)
      client.update!(type, params.reverse_merge(Id: id))
    end

    def destroy(type, id)
      client.destroy!(type, id) if id
    end

    def soft_delete(type, id)
      return unless id
      attrs = { "IsDeleted" => true, Id: id }
      update(type, id, attrs)
    end

    def find_account(organization_id)
      find('Account', organization_id.to_s, 'UNGC_ID__c')
    end

    def find_contact(contact_id)
      find('Contact', contact_id.to_s, 'UNGC_Contact_ID__c')
    end

    def find_local_network(local_network_id)
      id = Crm::Adapters::LocalNetwork.convert_id(local_network_id)
      find(Crm::LocalNetworkSyncJob::SObjectName, id, "External_ID__c")
    end

    def find_action_platform(platform_id)
      find(Crm::ActionPlatform::PlatformSyncJob::SObjectName, platform_id.to_s, "UNGC_Action_Platform_ID__c")
    end

    def find_action_platform_subscription(subscription_id)
      find(Crm::ActionPlatform::SubscriptionSyncJob::SObjectName, subscription_id.to_s, "UNGC_AP_Subscription_ID__c")
    end

  end

end
