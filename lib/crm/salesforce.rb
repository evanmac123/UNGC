module Crm
  class Salesforce
    attr_reader :client

    def initialize(client = nil, log: false)
      @client = client || begin
        config = DEFAULTS[:salesforce]
        ::Restforce.log = log
        ::Restforce.new(
          api_version: "36.0",
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
      puts message if Rails.env.development?
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
      client.destroy!(type, id)
    end

    def soft_delete(type, id)
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
      id = LocalNetworkAdapter.convert_id(local_network_id)
      find(LocalNetworkSync.crm_field_name, id, "External_ID__c")
    end

    def find_action_platform(platform_id)
      find(ActionPlatformSync::SObjectName, platform_id.to_s, "UNGC_Action_Platform_ID__c")
    end

    def find_action_platform_subscription(subscription_id)
      find(ActionPlatformSubscriptionSync::SObjectName,
        subscription_id.to_s,
        "UNGC_AP_Subscription_ID__c"
      )
    end

    def self.coerce(value)
      case value
      when Numeric, String, NilClass
        value
      when TrueClass
        true
      when FalseClass
        false
      when ActiveSupport::TimeWithZone
        # YYYY-MM-DDThh:mm:ss.sssZ
        value.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      when Date
        # YYYY-MM-DD
        value.strftime("%Y-%m-%d")
      when Hash
        value.transform_values { |v| coerce(v) }
      else
        raise "Unexpected type: #{value.class}"
      end
    end

  end

end
