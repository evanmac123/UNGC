require 'csv'

class GroupedReport
  include ActionView::Helpers::TagHelper

  def initialize(options={})
    @options = options
  end

  def render_html
    buffer = ''
    records.each_with_index do |dataset, i|
      if dataset.any?
        dataset_buffer = content_tag(:h3, titles[i])

        dataset_buffer << dataset.collect do |r|
          content_tag(:p, row(r)[i].join(","))
        end.join

        buffer << content_tag(:div, dataset_buffer)
      end
    end

    return buffer
  end

  def render_xls
    buffer = ''
    records.each_with_index do |dataset, i|
      buffer << CSV.generate_line([titles[i]], :col_sep => "\t")
      buffer << CSV.generate_line(headers[i], :col_sep => "\t")
      CSV.generate(buffer, :col_sep => "\t") do |csv|
        dataset.each do |r|
          csv << row(r)[i]
        end
      end
      buffer << CSV.generate_line([nil], :col_sep => "\t")
    end
    return buffer
  end
end
