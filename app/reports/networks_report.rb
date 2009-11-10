class NetworksReport < GroupedReport
  def records
    [Organization.without_contacts.all(:limit => 5),
      Organization.all(:limit => 5)]
  end
  
  def titles
    ['Participants that became Non-Communicating in the last 90 days',
      'Participants at risk of becoming Non-Communicating in the next 90 days',
      'Participants that became Inactive in the last 90 days',
      'Participants at risk of becoming Inactive in the next 90 days',
      'Participants Submitting a COP in the last 90 days',
      'Participants joined the UN Global Compact in the last 90 days']
  end
  
  def headers
    [['Organization', 'Type', 'Country', 'COP Due Date'],
      ['Organization', 'Type', 'Country', 'COP Due Date'],
      ['Organization', 'Type', 'Country', 'Inactive Date'],
      ['Organization', 'Type', 'Country', 'Inactive Date'],
      ['Organization', 'Type', 'Country', 'COP Submission Date'],
      ['Organization', 'Type', 'Country', 'Joining Date']]
  end

  def row(record)
    standard = [
      record.name, 
      record.organization_type.name, 
      record.country.name, 
      record.created_at
    ]
    became_non_communicating_90 = standard
    risk_non_communicating_90   = standard
    became_inactive_90          = standard
    risk_inactive_90            = standard
    submitted_90                = standard
    joined_90                   = standard
    
    [
      became_non_communicating_90,
      risk_non_communicating_90,
      became_inactive_90,
      risk_inactive_90,
      submitted_90,
      joined_90
    ]
  end
end