class LocalNetworkParticipantBreakdown < SimpleReport

  def records
    user = Contact.find(@options[:contact_id])
    Organization.
      visible_to(user).
      participants.
      with_cop_info.
      includes(:parent_company)
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [
      'Participant ID',
      'Join Date',
      'Participant Name',
      'Organization Type',
      'Country',
      'Sector',
      'Number of Employees',
      'Engagement Tier',
      'Bracketed Revenue',
      'Annual Revenue',
      'Invoice Date',
      'Parent Company Name',
      'Parent Company ID',
      'FT500',
      'COP Status',
      'Join Year',
      'COP Due Date',
      'Number of COPs',
      'Date of Last COP',
      'Projected Delisting',
      'Listed Status',
      'Stock Code',
      'Exchange',
      'Expelled on',
      'Readmitted on',
      'Member of Local Network'
    ]
  end

  def row(record)
  [ record.id,
    record.joined_on,
    record.name,
    record.organization_type_name,
    record.country_name,
    record.sector_name,
    record.employees,
    record.level_of_participation,
    record.revenue_description,
    record.precise_revenue.try!(:format),
    record.invoice_date,
    record.parent_company.try!(:name),
    record.parent_company_id,
    record.is_ft_500,
    record.cop_state.titleize,
    record.joined_on.try(:year),
    record.cop_due_on,
    record.cop_count,
    record.latest_cop.try(:to_date),
    record.try(:delisting_on),
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name),
    record.delisted_on.try(:to_date),
    record.rejoined_on.try(:to_date),
    record.is_local_network_member
  ]
  end
end
