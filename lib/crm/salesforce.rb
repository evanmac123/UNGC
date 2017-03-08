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
    end

    def update(type, id, params)
      client.update!(type, params.reverse_merge(Id: id))
    end

    def destroy(type, id)
      client.destroy!(type, id)
    end

    def find_account(organization_id)
      query = "select Id from Account where AccountNumber = '#{organization_id}'"
      accounts = client.query(query)
      accounts.first
    end

    def find_contact(contact_id)
      client.find('Contact', contact_id, 'UNGC_Contact_ID__c')
    rescue Faraday::Error::ResourceNotFound
      nil
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
      end
    end

  end

end
