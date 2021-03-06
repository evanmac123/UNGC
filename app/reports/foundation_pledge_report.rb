class FoundationPledgeReport < SimpleReport
  def records
    Organization.active
      .participants
      .companies_and_smes
      .joined_on(@options[:month].to_i, @options[:year].to_i)
      .order('joined_on')
  end

  def headers
    [ 'Financial Contact',
      'Financial Contact Email',
      'Financial Contact Phone',
      'Contact Point',
      'Contact Point Email',
      'Contact Point Phone',
      'Company',
      'Country',
      'Number of Employees',
      'Invoice ID',
      'Pledge',
      'Reason for not pledging',
      'Revenue',
      'Invoice Date',
      'Relationship Manager']
  end

  def row(r)
    [ r.financial_contact_or_contact_point.try(:name),
      r.financial_contact_or_contact_point.try(:email),
      r.financial_contact_or_contact_point.try(:phone),
      r.contacts.contact_points.first.try(:name),
      r.contacts.contact_points.first.try(:email),
      r.contacts.contact_points.first.try(:phone),
      r.name,
      r.country_name,
      r.employees,
      r.invoice_id,
      r.pledge_amount,
      r.no_pledge_reason_value,
      r.revenue_description,
      r.joined_on,
      r.participant_manager_name ]
  end
end
