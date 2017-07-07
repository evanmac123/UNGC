module Igloo
  class StaffSync

    def initialize(api, query = nil)
      @api = api
      @query = query || StaffQuery.new
      @csv_adapter = CsvAdapter.new
    end

    def upload_recent(cutoff)
      contacts = @query.recent(cutoff)
      converted = contacts.map(&method(:convert))
      csv = @csv_adapter.to_csv(converted)
      @api.bulk_upload(csv)
      contacts.count
    end

    def convert(contact)
      {
        "firstname" => contact.first_name,
        "lastname" => contact.last_name,
        "email" => contact.email,
        "customIdentifier" => contact.id,
        "country" => "USA",
        "company" => "UNGC",
        "occupation" => contact.job_title,
        "groupsToAdd" => "Administrators",
      }
    end
  end
end
