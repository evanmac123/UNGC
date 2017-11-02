class ParticipantBreakdownReport < SimpleReport

  def records
    Organization.participants.with_cop_info
  end

  def render_output
    self.render_xls_in_batches
  end


  def headers
    [ 'Participant ID',
      'Old ID',
      'Join Date',
      'Organization Type',
      'Country',
      'Company Name',
      'Sector',
      'Number of Employees',
      'Revenue',
      'FT500',
      'Region',
      'COP Status',
      'Active?',
      'Join Year',
      'COP Due Date',
      'Number of COPs',
      'Date of Last COP',
      'Inactive on',
      'Projected Delisting',
      'Listed Status',
      'Stock Code',
      'Exchange',
      'Expelled on',
      'Readmitted on',
      'Member of Local Network',
      'Engagement Level',
      'Revenue',
      'Invoice Date',
      'Parent Company'
    ]
  end

  def row(record)
  [ record.id,
    record.old_id,
    record.joined_on,
    record.organization_type.name,
    record.country_name,
    record.name,
    record.sector_name,
    record.employees,
    record.revenue_description,
    record.is_ft_500,
    record.region_name,
    record.cop_state.titleize,
    record.active,
    record.joined_on.try(:year),
    record.cop_due_on,
    record.cop_count,
    record.latest_cop.try(:to_date),
    record.inactive_on,
    record.try(:delisting_on),
    record.listing_status.try(:name),
    record.stock_symbol,
    record.exchange.try(:name),
    record.delisted_on.try(:to_date),
    record.rejoined_on.try(:to_date),
    record.is_local_network_member,
    organization_participation_level(record),
    organization_revenue(record),
    organization_invoice_date(record),
    parent_company_name(record)
  ]
  end

  private

  def parent_company_name(organization)
    parent_company = organization.parent_company_id
    if parent_company.nil?
      "None"
    else
      Organization.find(parent_company).name
    end
  end

  def organization_revenue(organization)
    amount = organization.precise_revenue
    if amount.nil?
      'Organization has not provided a revenue'
    else
      amount.format
    end
  end

  def organization_participation_level(organization)
    level_of_participation = organization.level_of_participation
    level_of_participation ? t(level_of_participation) : 'Level of engagement is not selected'
  end

  def organization_invoice_date(organization)
    invoice_date = organization.invoice_date
    invoice_date ? invoice_date : 'Organization currently has no invoice date'
  end

end
