require 'csv'

class SimpleFormatter
  include ActionView::Helpers::TagHelper
  
  def render_html(records)
    buffer = records.collect do |r|
      content_tag(:li, row(r).join(","))
    end
    content_tag :ul, buffer.join
  end

  def render_csv(records)
    buffer = CSV.generate_line(headers)
    CSV.generate(buffer) do |csv|
      records.each do |r|
        csv << row(r)
      end
    end
    return buffer
  end
end