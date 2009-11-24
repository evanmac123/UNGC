# == Schema Information
#
# Table name: searchables
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)
#  content           :text
#  url               :string(255)
#  document_type     :string(255)
#  last_indexed_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  delta             :boolean(1)      default(TRUE), not null
#  object_created_at :datetime
#  object_updated_at :datetime
#

class SearchableHelper
  include ActionView::Helpers
  # include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  # include ActionView::Helpers::SanitizeHelper
  default_url_options[:host] = DEFAULTS[:url_host]
end

require 'ostruct'

class Searchable < ActiveRecord::Base
  before_create :set_object_created_at
  before_save   :set_object_updated_at
  before_save   :set_indexed_at
  attr_accessor :object
  
  extend SearchableCaseStory
  extend SearchableEvent
  extend SearchableFiles
  extend SearchableHeadline
  extend SearchableOrganization
  extend SearchablePage
  extend SearchableCommunicationOnProgress
  
  define_index do
    indexes title
    indexes content
    has document_type, :facet => true
    has url, last_indexed_at
    set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
    set_property :field_weights => {"title" => 100}
  end
  
  class << self 
    def convert_to_utf8(text)
      converter = Iconv.new('UTF-8', text.encoding.name)
      converter.iconv(text)
    end

    def faceted_search(document_type, keyword, options={})
      options.merge!({with: {document_type_facet: document_type.to_crc32 } })
      search keyword, options
    end

    def import(document_type, options)
      url = options.delete(:url)
      searchable = find_by_url(url) || create(url: url, object: options.delete(:object))
      searchable.attributes = {document_type: document_type}.merge(options || {})
      searchable.save
      searchable
    end

    def index_all
      index_pages
      index_events
      index_headlines
      index_case_stories
      index_organizations
      index_communications_on_progress
    end

    def with_helper(&block)
      unless @helper
        @helper = SearchableHelper.new
      end
      @helper.instance_eval(&block)
    end
  end

  def set_indexed_at
    self.last_indexed_at = Time.now
  end

  def set_object_created_at
    self.object_created_at ||= object.created_at if object && object.respond_to?(:created_at)
  end

  def set_object_updated_at
    self.object_updated_at = object.updated_at if object && object.respond_to?(:updated_at)
  end

end
