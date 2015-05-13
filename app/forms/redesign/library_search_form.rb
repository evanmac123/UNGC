class Redesign::LibrarySearchForm
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

  def active_filters
    filters.flat_map(&:selected_options)
  end

  def issue_filter
    @issue_filter ||= Filters::IssueFilter.new(issue_areas, issues, key: 'issue_areas')
  end

  def topic_filter
    @topic_filter ||= Filters::TopicFilter.new(topic_groups, topics, key: 'topic_groups')
  end

  def sector_filter
    @sector_filter ||= Filters::SectorFilter.new(sector_groups, sectors, key: 'sector_groups')
  end

  def language_filter
    @language_filter ||= Filters::LanguageFilter.new(languages)
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
    options = {}

    add_issue_options(options)
    add_topic_options(options)
    add_sector_options(options)

    if languages.any?
      options[:language_ids] = languages
    end

    if content_type.present?
      options[:content_type] = content_type
    end

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
    Resource.search(keywords, options)
  end

  def keywords
    Riddle::Query.escape(super)
  end

  private

  # TODO push this into SearchFilter
  def add_issue_options(options)
    ids = Set.new(issues)
    areas = Issue.includes(:children).find(issue_areas)
    areas.each do |area|
      ids << area.id
      ids += area.children.map(&:id)
    end

    if ids.any?
      options[:issue_ids] = ids.to_a
    end
  end

  def add_topic_options(options)
    ids = Set.new(topics)

    parents = Topic.includes(:children).find(topic_groups)
    parents.each do |parent|
      ids << parent.id
      ids += parent.children.map(&:id)
    end

    if ids.any?
      options[:topic_ids] = ids.to_a
    end
  end

  def add_sector_options(options)
    ids = Set.new(sectors)

    parents = Sector.includes(:children).find(sector_groups)
    parents.each do |parent|
      ids << parent.id
      ids += parent.children.map(&:id)
    end

    if ids.any?
      options[:sector_ids] = ids.to_a
    end

  end

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

end
