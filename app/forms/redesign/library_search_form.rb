class Redesign::LibrarySearchForm
  include Virtus.model

  attribute :issue_areas,         Array[Integer], default: []
  attribute :issues,              Array[Integer], default: []
  attribute :topic_groups,        Array[Integer], default: []
  attribute :topics,              Array[Integer], default: []
  attribute :languages,           Array[Integer], default: []
  attribute :sector_groups,       Array[Integer], default: []
  attribute :sectors,             Array[Integer], default: []
  attribute :content_type,        Array[Integer], default: []
  attribute :keywords,            String,         default: ''
  attribute :page,                Integer
  attribute :per_page,            Integer,        default: 12
  attribute :sort_field,          String,         default: 'year desc'

  Filter = Struct.new(:id, :type, :name, :active)

  def initialize(page = 1, params = {})
    super(params)
    self.page = page
  end

  def active_filters
    issue_areas = issue_options.map(&:first).select(&:active)
    issues = issue_options.flat_map do |group, issues|
      issues.select(&:active)
    end

    topic_groups = topic_options.map(&:first).select(&:active)
    topics = topic_options.flat_map do |group, topics|
      topics.select(&:active)
    end

    sector_groups = sector_options.map(&:first).select(&:active)
    sectors = sector_options.flat_map do |group, sectors|
      sectors.select(&:active)
    end

    languages = language_options.select(&:active)

    [issue_areas, issues, topic_groups, topics, languages, sector_groups, sectors].flatten
  end

  def issue_options
    @issue_options ||= Redesign::IssueTree.new.map do |area, children|
      [
        Filter.new(area.id, :issue_area, area.name, issue_areas.include?(area.id)),
        children.map { |issue|
          Filter.new(issue.id, :issue, issue.name, issues.include?(issue.id))
        }
      ]
      end
  end

  def topic_options
    @topic_options ||= Redesign::TopicTree.new.map do |parent, children|
        [
          Filter.new(parent.id, :topic_group, parent.name, topic_groups.include?(parent.id)),
          children.map { |topic|
            Filter.new(topic.id, :topic, topic.name, topics.include?(topic.id))
          }
        ]
      end
  end

  def language_options
    @language_options ||= Language.all.map do |language|
      Filter.new(
        language.id, :language,
        language.name, languages.include?(language.id))
    end
  end

  def sector_options
    @sector_options ||= Redesign::SectorTree.new.map do |parent, children|
      [
        Filter.new(parent.id, :sector_group, parent.name, sector_groups.include?(parent.id)),
        children.map { |sector|
          Filter.new(sector.id, :sector, sector.name, sectors.include?(sector.id))
        }
      ]
    end
  end

  def type_options
    @type_options ||= Resource.content_types.to_a.map do |name, id|
      title = I18n.t("resources.types.#{name}")
      [title, id]
    end
  end

  def sort_options
    @sort_options ||= [
      ["Date",          :date],
      ["Title (A-Z)",   :title_asc],
      ["Title (Z-A)",   :title_desc],
    ]
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

    order = case self.sort_field
    when 'date'
      'year desc'
    when 'title_asc'
      'title asc'
    when 'title_desc'
      'title desc'
    else
      'year desc'
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

  def add_issue_options(options)
    ids = Set.new(issues)
    areas = Issue.includes(:children).find(issue_areas)
    areas.each do |area|
      if area.children.any?
        ids += area.children
      else
        ids << area.id
      end
    end

    if ids.any?
      options[:issue_ids] = ids.to_a
    end
  end

  def add_topic_options(options)
    ids = Set.new(topics)

    parents = Topic.includes(:children).find(topic_groups)
    parents.each do |parent|
      if parent.children.any?
        ids += parent.children
      else
        ids << parent.id
      end
    end

    if ids.any?
      options[:topic_ids] = ids.to_a
    end
  end

  def add_sector_options(options)
    ids = Set.new(sectors)

    parents = Sector.includes(:children).find(sector_groups)
    parents.each do |parent|
      if parent.children.any?
        ids += parent.children
      else
        ids << parent.id
      end
    end

    if ids.any?
      options[:sector_ids] = ids.to_a
    end

  end

end
