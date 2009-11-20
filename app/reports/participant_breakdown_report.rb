class ParticipantBreakdownReport < SimpleReport
  def records
    Organization.all(:include => [:country, :exchange], :limit => 100 )
  end
  
  def headers
    [ 'Participant ID',
      'Join Date',
      'Organization Type',
      'Country',
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
      'Stock Code',
      'Exchange'
    ]
  end

  def row(record)
  [ record.id,
    record.joined_on,
    record.organization_type.name,
    record.country.name,
    record.name,
    record.sector_name,
    record.employees,
    record.is_ft_500,
    record.country.region,
    record.cop_status_name,
    record.active,
    record.joined_on.try(:year),
    record.cop_due_on,
    record.inactive_on,
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name)
  ]
  end
end