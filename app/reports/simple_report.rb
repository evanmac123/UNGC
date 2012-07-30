require 'csv'

class SimpleReport
  include ActionView::Helpers

  def initialize(options={})
    @options = options
  end

  # by default render_xls unless overrided with render_xls_in_batches
  def render_output
    self.render_xls
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

  def render_xls_in_batches
    buffer = CSV.generate_line(headers, :col_sep => "\t")
    CSV.generate(buffer, :col_sep => "\t") do |csv|
      records.find_in_batches do |record|
        record.each {|r| csv << row(r) }
      end
    end
  end

end