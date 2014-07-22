# == Schema Information
#
# Table name: searchables
#
#  id                :integer          not null, primary key
#  title             :string(255)
#  content           :text
#  url               :string(255)
#  document_type     :string(255)
#  last_indexed_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  delta             :boolean          default(TRUE), not null
#  object_created_at :datetime
#  object_updated_at :datetime
#

class SearchableHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper
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
  extend SearchableResource

  define_index do
    indexes title
    indexes content
    has document_type, :as => :document_type, :facet => true
    has url, last_indexed_at
    set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
    set_property :field_weights => {"title" => 100}

    set_property :enable_star => true
    set_property :min_prefix_len => 4
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

    # The intent here appears to be that this method is called manually once at
    # install time to seed the Searchables table. See index_new_or_updated.
    def index_all
      index_pages
      index_events
      index_headlines
      index_case_stories
      index_organizations
      index_communications_on_progress
      index_resources
    end

    # This method is called by cron to periodically update the searchables.
    # See scripts/cron/searchable
    def index_new_or_updated(since = nil)
      max = since || find(:all, select: 'MAX(last_indexed_at) as max').first.try(:max)
      raise "You can't call index_new_or_updated unless you've run index_all at least once".inspect unless max
      index_pages_since(max)
      index_events_since(max)
      index_headlines_since(max)
      index_case_stories_since(max)
      index_organizations_since(max)
      index_communications_on_progress_since(max)
      index_resources_since(max)
    end

    def new_or_updated_since(time)
      ["(created_at > ?) OR (updated_at > ?)", time, time]
    end

    def with_helper(&block)
      unless @helper
        @helper = SearchableHelper.new
      end
      @helper.instance_eval(&block)
    end

    def remove(document_type, url)
      where(document_type: document_type, url: url).destroy_all
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
