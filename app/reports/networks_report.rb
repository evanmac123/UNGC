class NetworksReport < GroupedReport
  def records
    [Organization.without_contacts.all(:limit => 5),
      Organization.all(:limit => 5)]
  end
  
  def titles
    ['Participants that became Non-Communicating in the last 90 days',
      'Participants at risk of becoming Non-Communicating in the next 90 days']
  end
  
  def headers
    [['name', 'Type', 'Country', 'COP Dude Date'],
      ['name', 'Type', 'Country', 'Inactive Date']]
  end

  def row(record)
    [[record.name, record.organization_type.name, record.country.name, record.created_at],
      [record.name, record.organization_type.name, record.country.name, record.created_at]]
  end
end