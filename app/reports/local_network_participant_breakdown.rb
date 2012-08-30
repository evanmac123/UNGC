class LocalNetworkParticipantBreakdown < SimpleReport

  def records
    Organization.participants_with_cop_info(sql_for_organization_scope)
  end

  def render_output
    self.render_xls_in_batches
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
      'Number of COPs',
      'Date of Last COP',
      'Listed Status',
      'Stock Code',
      'Exchange',
      'Expelled on',
      'Readmitted on'
    ]
  end

  def row(record)
  [ record.id,
    record.joined_on,
    record.organization_type.name,
    record.country_name,
    record.name,
    record.sector_name,
    record.employees,
    record.is_ft_500,
    record.region_name,
    record.cop_state.titleize,
    record.active,
    record.joined_on.try(:year),
    record.cop_due_on,
    record.cop_count,
    record.latest_cop.try(:to_date),
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name),
    record.delisted_on.try(:to_date),
    record.rejoined_on.try(:to_date)
  ]
  end
end
