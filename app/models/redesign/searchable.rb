class SearchableHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper
  default_url_options[:host] = DEFAULTS[:url_host]
end

class Redesign::Searchable < ActiveRecord::Base
  before_save   :set_indexed_at

  extend Redesign::Searchable::SearchableResource
  extend Redesign::Searchable::SearchableContainer
  extend Redesign::Searchable::SearchableCommunicationOnProgress
  extend Redesign::Searchable::SearchableHeadline
  extend Redesign::Searchable::SearchableOrganization

  #extend Redesign::Searchable::SearchableEvent

  class << self
    def convert_to_utf8(text)
      text.encode('UTF-8')
    end

    def faceted_search(document_type, keyword, options={})
      matching_facets = self.facets(keyword, options)
      matching_facets.for(document_type: document_type)
    end

    def import(document_type, options)
      url = options.delete(:url)
      searchable = where(url: url).first_or_initialize
      searchable.attributes = {document_type: document_type}.merge(options || {})
      searchable.save
      searchable
    end

    # The intent here appears to be that this method is called manually once at
    # install time to seed the Searchables table. See index_new_or_updated.
    def index_all
      index_resources
      index_containers
      index_communications_on_progresses
      index_headlines
      index_organizations
    end

    # This method is called by cron to periodically update the searchables.
    # See scripts/cron/searchable
    def index_new_or_updated(since = nil)
      max = since || maximum(:last_indexed_at)
      raise "You can't call index_new_or_updated unless you've run index_all at least once".inspect unless max
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

  private
  def set_indexed_at
    self.last_indexed_at = Time.now
  end
end
