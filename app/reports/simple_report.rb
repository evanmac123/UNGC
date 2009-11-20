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
    header = headers.join("\t") + "\n"
    rows = records.collect do |r|
      row(r).join("\t")
    end
    return header + rows.join("\n")
  end
  
end