class Redesign::LibrarySearchForm < Redesign::FilterableForm
  include Virtus.model

  attribute :issue_areas,         Array[Integer], default: []
  attribute :issues,              Array[Integer], default: []
  attribute :topic_groups,        Array[Integer], default: []
  attribute :topics,              Array[Integer], default: []
  attribute :languages,           Array[Integer], default: []
  attribute :sector_groups,       Array[Integer], default: []
  attribute :sectors,             Array[Integer], default: []
  attribute :content_type,        String,         default: ''
  attribute :keywords,            String,         default: ''
  attribute :page,                Integer
  attribute :per_page,            Integer,        default: 12
  attribute :sort_field,          String,         default: 'year desc'

  def initialize(page = 1, params = {})
    super(params)
    self.page = page
  end

  def filters
    [issue_filter, topic_filter, language_filter, sector_filter]
  end

  def issue_filter
    @issue_filter ||= begin
      filter = Filters::IssueFilter.new(issue_areas, issues, key: 'issue_areas')
      exclude_empty_facets(filter, facet: :issue_ids)
    end
  end

  def topic_filter
    @topic_filter ||= begin
      filter = Filters::TopicFilter.new(topic_groups, topics, key: 'topic_groups')
      exclude_empty_facets(filter, facet: :topic_ids)
    end
  end

  def sector_filter
    @sector_filter ||= begin
      filter = Filters::SectorFilter.new(sector_groups, sectors, key: 'sector_groups')
      exclude_empty_facets(filter, facet: :sector_ids)
    end
  end

  def language_filter
    @language_filter ||= begin
      filter = Filters::LanguageFilter.new(languages)
      exclude_empty_facets(filter, facet: :language_ids)
    end
  end

  def type_options
    @type_options ||= format_content_types
  end

  def sort_options
    @sort_options ||= [
      ["Date",          :date],
      ["Title (A-Z)",   :title_asc],
      ["Title (Z-A)",   :title_desc],
    ]
  end

  def disabled?
    active_filters.count >= 5
  end

  def options
    options = {
      issue_ids: issue_filter.effective_selection_set,
      topic_ids: topic_filter.effective_selection_set,
      language_ids: languages,
      sector_ids: sector_filter.effective_selection_set,
      content_type: content_type,
    }.reject { |_, value| value.blank? }

    {
      indices: ['resource_new_core'],
      page: self.page || 1,
      per_page: self.per_page || 12,
      order: order,
      star: true,
      with: options,
    }
  end

  def execute
    Resource.search(escaped_keywords, options)
  end

  def escaped_keywords
    Redesign::SearchEscaper.escape(keywords)
  end

  private

  def order
    case self.sort_field
    when 'date'
      'year desc'
    when 'title_asc'
      'title asc'
    when 'title_desc'
      'title desc'
    else
      'year desc'
    end
  end

  def format_content_types
    Resource.content_types
      .to_a
      .sort
      .map do |name, id|
        title = I18n.t("resources.types.#{name}")
        [title, id]
      end
  end

  module NoResultFilter

    def matching_ids=(matching_ids)
      @matching_ids = matching_ids
    end

    def options
      # options may be nested or flat...
      # it's unfortunate that we know these implementation details
      # perhaps this can be re-worked later.
      super.map do |parent, children|
        if children.present?
          [parent, children.select {|child| option_enabled?(child)}]
        else
          parent
        end
      end
      .select do |parent, children|
        option_enabled?(parent) || Array(children).any?
      end
    end

    private

    def option_enabled?(item)
      @matching_ids.include?(item.id)
    end

  end

  def exclude_empty_facets(filter, facet: nil)
    filter.extend(NoResultFilter)
    filter.matching_ids = matching_facets(facet).keys
    filter
  end

  def matching_facets(key)
    @_facets ||= Resource.facets(keywords, {indices: ['resource_new_core']})
    @_facets[key]
  end

end
