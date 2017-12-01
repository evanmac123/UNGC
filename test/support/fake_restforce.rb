class FakeRestforce

  def initialize
    @records = {
      'Account' => {},
      'Contact' => {},
      Crm::LocalNetworkSync.crm_field_name => {},
      Crm::DonationSync::SObjectName => {},
    }
  end

  def query(query)
    pattern = /select Id from ([^ ]+) where AccountNumber = '(\d+)'/
    match = pattern.match(query)
    if match
      type = match[1]
      id = match[2].to_i

      models = @records.fetch(type)
      models.values.select do |model|
        model.AccountNumber == id
      end
    else
      []
    end
  end

  def create!(type, params)
    models = @records.fetch(type)

    id = "crm_#{type.downcase}_#{models.count + 1}"
    record = ::Restforce::SObject.new(params.merge(Id: id))

    models[id] = record
    record
  end

  def destroy!(type, id)
    models = @records.fetch(type)
    models.delete(id)
    id
  end

  def update!(type, params)
    model = @records.fetch(type)

    id = params.fetch(:Id)
    record = model.fetch(id)
    updated_record = ::Restforce::SObject.new(record.attrs.merge(params))
    model[id] = updated_record
    updated_record
  end

  def find(type, value, field_name)
    models = @records.fetch(type)

    models.values.detect do |model|
      model[field_name].to_s == value.to_s
    end
  end

  # helpers

  def find_account(organization_id)
    Crm::Salesforce.new(self).find_account(organization_id)
  end

  def find_contact(contact_id)
    Crm::Salesforce.new(self).find_contact(contact_id)
  end

end
