require 'csv'

class LogoRequestFormatter
  def render_html(records)
    "html report"
  end

  def render_csv(records)
    buffer = ""
    buffer << CSV.generate_line(['Company', 'Sector', 'Country', 'Publication Type',
                                  'Reviewer', 'Approval Date', 'Days to process'])
    records.each do |r|
      # TODO user r.approved_on instead of r.accepted_on
      row = [r.organization.name, r.organization.sector.name, r.organization.country.name, r.publication.name,
              r.reviewer.name, r.accepted_on, r.days_to_process]
      buffer << CSV.generate_line(row)
    end
    return buffer
  end
end