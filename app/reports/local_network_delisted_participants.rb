class LocalNetworkDelistedParticipants < SimpleReport

  def records
    contact = Contact.find(@options.fetch(:contact_id))
    Organization.visible_to(contact).with_cop_info.with_cop_status(:delisted)
  end

  def render_output
    self.render_xls
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
    record.delisted_on.try(:to_date),
    record.organization_type_name,
    record.is_ft_500,
    record.sector_name,
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name),
    record.country_name,
    record.latest_cop.try(:to_date),
    record.cop_count,
    record.removal_reason.try(:description)
  ]
  end

end
