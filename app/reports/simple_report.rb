require 'csv'

class SimpleReport
  include ActionView::Helpers::TagHelper

  def initialize(options={})
    @options = options
  end
  
  def render_html
    buffer = records.collect do |r|
      content_tag(:li, row(r).join(","))
    end
    content_tag :ul, buffer.join
  end

  def render_csv
    buffer = CSV.generate_line(headers)
    CSV.generate(buffer) do |csv|
      records.each do |r|
        csv << row(r)
      end
    end
    return buffer
  end
end