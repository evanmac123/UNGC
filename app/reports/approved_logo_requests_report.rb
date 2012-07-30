class ApprovedLogoRequestsReport < SimpleReport

  def records
    LogoRequest.approved_between(@options[:month].to_i, @options[:year].to_i)
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
