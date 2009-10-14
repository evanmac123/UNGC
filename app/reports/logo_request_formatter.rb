require 'csv'

class LogoRequestFormatter
  include ActionView::Helpers::TagHelper
  
  def render_html(records)
    buffer = records.collect do |r|
      content_tag(:li, [r.organization.name, r.organization.sector.name, r.organization.country.name,
                          r.publication.name, r.reviewer.name, r.accepted_on, r.days_to_process].join(","))
    end
    content_tag :ul, buffer.join
  end

  def render_csv(records)
    buffer = CSV.generate_line(['Company', 'Sector', 'Country', 'Publication Type',
                                  'Reviewer', 'Approval Date', 'Days to process'])
    
    CSV.generate(buffer) do |csv|
      records.each do |r|
        # TODO user r.approved_on instead of r.accepted_on
        csv << [r.organization.name, r.organization.sector.name, r.organization.country.name,
                r.publication.name, r.reviewer.name, r.accepted_on, r.days_to_process]
      end
    end
    
    return buffer
  end
end