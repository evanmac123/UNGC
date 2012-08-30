require 'csv'
require 'tempfile'

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
    file = Tempfile.new('xls')
    CSV.open(file.path, 'w+', :col_sep => "\t") do |line|
      line << headers
      records.each do |record|
        line << row(record)
      end
    end
    file
  end

  def render_xls_in_batches
    file = Tempfile.new('xls')
    CSV.open(file.path, 'w+', :col_sep => "\t") do |line|
      line << headers
      records.find_in_batches do |record|
        record.each {|r| line << row(r) }
      end
    end
    file
  end

  protected

  def sql_for_organization_scope(table_name=Organization.table_name)
    if @options[:user].try(:from_network?)
      Organization.send(:sanitize_sql_for_conditions, {:country_id => @options[:user].local_network.country_ids}, table_name)
    else
      "1"
    end
  end

end