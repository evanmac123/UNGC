# == Schema Information
#
# Table name: searchables
#
#  id              :integer(4)      not null, primary key
#  title           :string(255)
#  content         :text
#  url             :string(255)
#  document_type   :string(255)
#  last_indexed_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class SearchableHelper
  # include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  # include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers
  default_url_options[:host] = DEFAULTS[:url_host]
end

class Searchable < ActiveRecord::Base
  before_save :set_indexed_at
  
  define_index do
    indexes title
    indexes content
    has url, document_type, last_indexed_at
  end

  def self.import(document_type, options)
    url = options.delete(:url)
    searchable = find_or_create_by_url(url)
    searchable.attributes = {:document_type => document_type}.merge(options || {})
    searchable.save
    searchable
  end
  
  def self.index_page(page)
    helper = SearchableHelper.new
    title = page.title
    content = helper.strip_tags page.content
    url = page.path
    import 'Page', :url => url, :title => title, :content => content
  end

  def self.index_pages
    Page.approved.each { |page| index_page page }
  end
  
  def self.index_pdf(system_path_to_file, public_path_to_file)
    title = 'PDF File'
    url   = public_path_to_file
    content = `pdf2txt.py #{system_path_to_file}`
    import 'PDF', :url => url, :title => title, :content => content
  end

  def set_indexed_at
    self.last_indexed_at = Time.now
  end
end
