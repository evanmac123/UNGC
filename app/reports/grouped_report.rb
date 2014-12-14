require 'csv'

class GroupedReport
  include ActionView::Helpers::TagHelper

  def initialize(options={})
    @options = options
  end

  # determines whether report calls render_xls or render_xls_in_batches
   def render_output
     self.render_xls
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

    # TODO refactor the buffer away and write directly to the file.
    file = Tempfile.new('xls')
    File.open(file.path, 'w+') do |file|
      file.write(buffer)
    end

    file
  end
end
