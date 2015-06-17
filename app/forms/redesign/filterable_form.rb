class Redesign::FilterableForm

  FilterInfo = Struct.new(:id, :options)

  module FilterMacros

    def self.included(clazz)
      clazz.extend ClassMethods
    end

    module ClassMethods
      attr_reader :filter_infos

      def filter(id, options = {})
        @filter_infos ||= []
        @filter_infos << FilterInfo.new(id, options)
      end

    end

  end

  include FilterMacros

  attr_reader :issue_filter, :topic_filter

  def initialize(*args)
    raise 'no'
  end

  def active_filters
    filters.flat_map(&:selected_options)
  end

  def disabled?
    false
  end

  def facets
    raise 'override me'
  end

  def filters
    materialized_filters.values
  end

  def issue_filter
    materialized_filters[:issue]
  end

  def topic_filter
    materialized_filters[:topic]
  end

  def sector_filter
    materialized_filters[:sector]
  end

  def language_filter
    materialized_filters[:language]
  end

  protected

  def materialized_filters
    @materialized_filters ||= self.class.filter_infos.each_with_object({}) do |filter_info, acc|
      key = filter_info.id
      acc[key] = send("create_#{key}_filter", filter_info.options)
    end
  end

  def create_issue_filter(options)
    parent_key = options.fetch(:parent, :issues)
    parents = public_send(parent_key)
    children = public_send(options.fetch(:children, :issues))
    facet = options.fetch(:facet, :issue_ids)

    filter = Filters::IssueFilter.new(parents, children, key: parent_key)
    Filters::FacetFilter.new(filter, enabled_facets(facet))
  end

  def create_topic_filter(options)
    parent_key = options.fetch(:parent, :topics)
    parents = public_send(parent_key)
    children = public_send(options.fetch(:children, :topics))
    facet = options.fetch(:facet, :topic_ids)

    filter = Filters::TopicFilter.new(parents, children, key: parent_key)
    Filters::FacetFilter.new(filter, enabled_facets(facet))
  end

  def create_sector_filter(options)
    parent_key = options.fetch(:parent, :sectors)
    parents = public_send(parent_key)
    children = public_send(options.fetch(:children, :sectors))
    facet = options.fetch(:facet, :sector_ids)

    filter = Filters::SectorFilter.new(parents, children, key: parent_key)
    Filters::FacetFilter.new(filter, enabled_facets(facet))
  end

  def create_language_filter(options)
    selected = public_send(options.fetch(:selected, :languages))
    facet = options.fetch(:facet, :language_ids)

    filter= Filters::LanguageFilter.new(selected)
    Filters::FacetFilter.new(filter, enabled_facets(facet))
  end

  def enabled_facets(key)
    @_facets ||= facets.to_h
    @_facets.fetch(key, {}).keys
  end

end
