module Igloo
  class LocalNetworkSync

    def initialize(api)
      @api = api
      @query = LocalNetworkQuery.new
      @csv_adapter = CsvAdapter.new
    end

    def upload_recent(cutoff)
      contacts = @query.recent(cutoff)
      converted = contacts.map(&method(:convert))
      csv = @csv_adapter.to_csv(converted)
      @api.bulk_upload(csv)
      converted.count
    end

    def convert(contact)
      {
        "customIdentifier" => contact.id.to_s,
        "firstname" => [contact.first_name, contact.middle_name].reject(&:blank?).join(" "),
        "lastname" => contact.last_name,
        "email" => contact.email,
        "address" => contact.address,
        "address2" => contact.address_more,
        "country" => contact.country.try!(:name),
        "zipcode" => contact.postal_code,
        "busphone" => contact.phone,
        "city" => contact.city,
        "state" => contact.state,
        "company" => "LN #{contact.local_network.name}",
        "occupation" => contact.roles.map(&:name).join(", "),
        "groupsToAdd" => "Local Network Members",
      }
    end

  end
end
