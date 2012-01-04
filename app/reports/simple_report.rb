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

  def render_xls
    buffer = CSV.generate_line(headers, :col_sep => "\t")
    CSV.generate(buffer, :col_sep => "\t") do |csv|
      records.each do |r|
        csv << row(r)
      end
    end
  end

end
