class FakeRestforce

  def initialize
    @records = {
      'Account' => {},
      'Contact' => {},
      Crm::LocalNetworkSyncJob::SObjectName => {},
      Crm::DonationSync::SObjectName => {},
      Crm::ActionPlatform::PlatformSyncJob::SObjectName => {},
      Crm::ActionPlatform::SubscriptionSyncJob::SObjectName => {},
    }
    @object_prefixes = {
        Crm::OrganizationSyncJob::SObjectName => '001', # ACCOUNT
        Crm::ContactSyncJob::SObjectName => '003', # CONTACT
        Crm::ActionPlatform::PlatformSyncJob::SObjectName => '605', # PRODUCT
        Crm::ActionPlatform::SubscriptionSyncJob::SObjectName => '00x', # BILLED_PRODUCT
        Crm::LocalNetworkSyncJob::SObjectName => '01I', # CUSTOM_ENTITY_DEFINITION
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

    model_count = models.count + 1
    record_id = if @object_prefixes[type]
      "#{@object_prefixes[type]}0D#{model_count.to_s.rjust(10, '0')}MVK"
    else
      "crm_#{type.downcase}_#{model_count}"
    end

    record = ::Restforce::SObject.new(params.merge(Id: record_id))

    models[record_id] = record
    record_id
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
