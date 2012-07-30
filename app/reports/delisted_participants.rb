class DelistedParticipants < SimpleReport

  def records
    Organization.delisted
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'Participant ID',
      'Participant Name',
      'Number of Employees',
      'Join Date',
      'Join Year',
      'Delisted Date',
      'Organization Type',
      'FT500',
      'Sector',
      'Listed Status',
      'Stock Code',
      'Exchange',
      'Country',
      'Region',
      'Latest COP',
      'Number of COPs',
      'Reason for Removal'
    ]
  end

  def row(record)
  [ record.id,
    record.name,
    record.employees,
    record.joined_on,
    record.joined_on.try(:year),
    record.delisted_on,
    record.organization_type.name,
    record.is_ft_500,
    record.sector_name,
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name),
    record.country.name,
    record.country.region_name,
    record.latest_cop.try(:to_date),
    record.cop_count,
    record.removal_reason.try(:description)
  ]
  end
end
