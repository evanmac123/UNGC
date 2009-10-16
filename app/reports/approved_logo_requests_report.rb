class ApprovedLogoRequestsReport < SimpleReport
  def records
    LogoRequest.approved.submitted_in(@options[:month].to_i, @options[:year].to_i)
  end
  
  def headers
    ['Company', 'Sector', 'Country', 'Publication Type', 'Reviewer',
      'Approval Date', 'Days to process']
  end

  def row(record)
    # TODO user r.approved_on instead of r.accepted_on
    [record.organization.name, record.organization.sector.try(:name), record.organization.country.name,
      record.publication.name, record.reviewer.name, record.accepted_on, record.days_to_process]
  end
end