class FoundationPledgeReport < SimpleReport
  def records
    Organization.with_pledge.created_in(@options[:month].to_i, @options[:year].to_i)
  end
  
  def headers
    ['Contact', 'Email', 'Company', 'Country', 'Invoice ID', 'Pledge',
      'Invoice Date', 'Days since invoiced']
  end

  def row(record)
    ["Contact", 'email@example.com', record.name, record.country.name, record.invoice_id,
      record.pledge_amount, record, created_at, record.days_since_invoiced]
  end
end