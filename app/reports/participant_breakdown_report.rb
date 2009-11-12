class ParticipantBreakdownReport < SimpleReport
  def records
    Organization.all(:include => [:country, :exchange], :limit => 10 )
  end
  
  def headers
    [ 'Participant ID',
      'Join Date',
      'Organization Type',
      'Country',
      'Stock Code',
      'Company Name',
      'Sector',
      'Number of Employees',
      'FT500',
      'Region',
      'COP Status',
      'Active?',
      'Join Year',
      'COP Due Date',
      'Inactive on',
      'Listed Status',
      'Exchange'
    ]
  end

  def row(record)
  [ record.id,
    record.joined_on,
    record.organization_type.name,
    record.country.name,
    record.stock_symbol,
    record.name,
    record.sector_name,
    record.employees,
    record.is_ft_500,
    record.country.region,
    record.cop_status,
    record.active,
    record.joined_on, # can't call record.joined_on.year ?
    record.cop_due_on,
    record.inactive_on,
    record.listing_status, # record.listing_status.name ?
    record.exchange # record.exchange.name ?
  ]
  end
end