class FilterableForm

  attr_writer :facet_cache

  def active_filters
    filters.flat_map(&:selected_options)
  end

  def disabled?
    false
  end

  def facets
    raise 'override me'
  end

  def facet_cache
    @facet_cache ||= FacetCache.new
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

  def country_filter
    materialized_filters[:country]
  end

  def headline_type_filter
    materialized_filters[:event_type]
  end

  def organization_type_filter
    materialized_filters[:organization_type]
  end

  def engagement_tier_filter
    materialized_filters[:engagement_tier]
  end

  def action_platform
    materialized_filters[:action_platform]
  end

  def initiative_filter
    materialized_filters[:initiative]
  end

  def sustainable_development_goal_filter
    materialized_filters[:sustainable_development_goal]
  end

  protected

  def reject_blanks(options)
    options.reject { |_, value| value.blank? }
  end

  def escape(keywords)
    SearchEscaper.escape(keywords)
  end

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

    facet_filter facet, Filters::IssueFilter.new(parents, children, key: parent_key)
  end

  def create_topic_filter(options)
    parent_key = options.fetch(:parent, :topics)
    parents = public_send(parent_key)
    children = public_send(options.fetch(:children, :topics))
    facet = options.fetch(:facet, :topic_ids)

    facet_filter facet, Filters::TopicFilter.new(parents, children, key: parent_key)
  end

  def create_sector_filter(options)
    parent_key = options.fetch(:parent, :sectors)
    parents = public_send(parent_key)
    children = public_send(options.fetch(:children, :sectors))
    facet = options.fetch(:facet, :sector_ids)

    facet_filter facet, Filters::SectorFilter.new(parents, children, key: parent_key)
  end

  def create_language_filter(options)
    selected = public_send(options.fetch(:selected, :languages))
    facet = options.fetch(:facet, :language_ids)

    facet_filter facet, Filters::LanguageFilter.new(selected)
  end

  def create_country_filter(options)
    selected = public_send(options.fetch(:selected, :countries))
    facet = options.fetch(:facet, :country_id)

    facet_filter facet, Filters::CountryFilter.new(selected)
  end

  def create_headline_type_filter(options)
    selected = public_send(options.fetch(:selected, :news_type))
    facet = options.fetch(:facet, :headline_type)

    facet_filter facet, Filters::HeadlineTypeFilter.new(selected)
  end

  def create_organization_type_filter(options)
    selected = public_send(options.fetch(:selected, :organization_types))
    facet = options.fetch(:facet, :organization_type_id)

    facet_filter facet, Filters::OrganizationTypeFilter.new(selected)
  end

  def create_engagement_tier_filter(options)
    selected = public_send(options.fetch(:selected, :engagement_tiers))
    facet = options.fetch(:facet, :engagement_tiers)

    facet_filter facet, Filters::EngagementTierFilter.new(selected)
  end

  def create_action_platform_filter(options)
    selected = public_send(options.fetch(:selected, :action_platforms))
    facet = options.fetch(:facet, :action_platforms)

    facet_filter facet, Filters::ActionPlatformFilter.new(selected)
  end

  def create_initiative_filter(options)
    selected = public_send(options.fetch(:selected, :initiatives))
    facet = options.fetch(:facet, :initiative_ids)

    facet_filter facet, Filters::InitiativeFilter.new(selected)
  end

  def create_sustainable_development_goal_filter(options)
    selected = public_send(options.fetch(:selected, :sustainable_development_goals))
    facet = options.fetch(:facet, :sustainable_development_goal_ids)

    facet_filter facet, Filters::SustainableDevelopmentGoalFilter.new(selected)
  end

  def enabled_facets(key)
    cache_key = self.class.name.underscore
    @_facets ||= facet_cache.fetch(cache_key) do
      facets.to_h
    end
    @_facets.fetch(key, {}).keys
  end

  def facet_filter(facet, filter)
    Filters::FacetFilter.new(filter, enabled_facets(facet))
  end

end
