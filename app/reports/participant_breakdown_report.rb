class ParticipantBreakdownReport < SimpleReport
  def records
    Organization.all(:include => [:country, :exchange], :limit => 100 )
  end
  
  def headers
    [ 'Participant ID',
      'Join Date',
      'Organization Type',
      'Country',
      'Stock Code',
      'Company Name',
      'Website',
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
    record.url,
    record.sector_name,
    record.employees,
    record.is_ft_500,
    record.country.region,
    record.cop_status,
    record.active,
    record.joined_on.try(:year),
    record.cop_due_on,
    record.inactive_on,
    record.listing_status.try(:name),
    record.exchange.try(:name)
  ]
  end
end