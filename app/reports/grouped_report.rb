require 'csv'

class GroupedReport
  include ActionView::Helpers::TagHelper

  def initialize(options={})
    @options = options
  end
  
  def render_html
    buffer = ''
    records.each_with_index do |dataset, i|
      dataset_buffer = content_tag(:h3, titles[i])
      
      dataset_buffer << dataset.collect do |r|
        content_tag(:p, row(r)[i].join(","))
      end.join
      
      buffer << content_tag(:div, dataset_buffer)
    end
    
    return buffer
  end

  def render_csv
    buffer = ''
    records.each_with_index do |dataset, i|
      buffer << CSV.generate_line([titles[i]])
      buffer << CSV.generate_line(headers[i])
      CSV.generate(buffer) do |csv|
        dataset.each do |r|
          csv << row(r)[i]
        end
      end
      buffer << CSV.generate_line([nil])
    end
    return buffer
  end
end