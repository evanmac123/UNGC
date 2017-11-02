require 'csv'
require 'securerandom'
require 'fileutils'

class SimpleReport
  include ActionView::Helpers
  include Admin::ReportsHelper

  TMPDIR = '/tmp/ungc-reports'
  TMPMOD = 0644

  attr_reader :options

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
    path = fetch_scratch_file
    CSV.open(path, 'w+', :col_sep => "\t") do |line|
      line << headers
      records.each do |record|
        line << row(record)
      end
    end
    path
  end

  def to_h
    records.map do |record|
      Hash[headers.zip(row(record))]
    end
  end

  def render_xls_in_batches
    path = fetch_scratch_file
    CSV.open(path, 'w+', :col_sep => "\t") do |line|
      line << headers
      records.find_in_batches do |record|
        record.each {|r| line << row(r) }
      end
    end
    path
  end

  protected

  def fetch_scratch_file
    @file ||= begin
      f = File.join(TMPDIR, "#{SecureRandom.hex}.csv")
      FileUtils.mkdir_p(TMPDIR)
      FileUtils.touch(f)
      FileUtils.chmod(TMPMOD, f)
      f
    end
  end

end
