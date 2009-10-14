require 'csv'

class SimpleOrganizationFormatter
  def render_html(records)
    "html report"
  end

  def render_csv(records)
    buffer = CSV.generate_line(['participant_name', 'type'])
    
    CSV.generate(buffer) do |csv|
      records.each {|r| csv << [r.name, r.organization_type.name]}
    end
    
    return buffer
  end
end