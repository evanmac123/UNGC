class FoundationPledgeReport < SimpleReport

  @render_method = :render_xls

  def records
    Organization.active.participants.companies_and_smes.joined_on(@options[:month].to_i, @options[:year].to_i)
  end

  def headers
    [ 'Contact',
      'Email',
      'Phone',
      'Company',
      'Country',
      'Number of Employees',
      'Invoice ID',
      'Pledge',
      'Invoice Date']
  end

  def row(r)
    [ r.financial_contact_or_contact_point.try(:name),
      r.financial_contact_or_contact_point.try(:email),
      r.financial_contact_or_contact_point.try(:phone),
      r.try(:name),
      r.country.try(:name),
      r.employees,
      r.invoice_id,
      r.pledge_amount,
      r.joined_on]
  end
end
