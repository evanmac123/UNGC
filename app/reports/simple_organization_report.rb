class SimpleOrganizationReport < SimpleReport
  def records
    Organization.without_contacts
  end

  def headers
    ['participant_name', 'type']
  end

  def row(record)
    [record.name, record.organization_type.name]
  end
end
