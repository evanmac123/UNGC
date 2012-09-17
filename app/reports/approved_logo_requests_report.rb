class ApprovedLogoRequestsReport < SimpleReport

  def records
    year  = @options[:year].to_i
    month = @options[:month].to_i

    start_date = Date.new(year, month, 1)
    end_date   = Date.new(year, month, 1).end_of_month

    LogoRequest.approved_between(start_date, end_date)
  end

  def headers
    [
      'Request ID',
      'Company',
      'Sector',
      'Country',
      'Publication Type',
      'Reviewer',
      'Approval Date',
      'State',
      'Days to process'
    ]
  end

  def row(record)
    [
      record.id,
      record.organization.try(:name),
      record.organization.sector.try(:name),
      record.organization.country.try(:name),
      record.publication.try(:name),
      record.reviewer.try(:name),
      record.approved_on,
      record.state,
      record.days_to_process
    ]
  end
end
