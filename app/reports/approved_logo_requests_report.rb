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
      record.organization.name,
      record.organization.sector.try(:name),
      record.organization.country.name,
      record.publication.name,
      record.reviewer.name,
      record.approved_on,
      record.state,
      record.days_to_process
    ]
  end
end