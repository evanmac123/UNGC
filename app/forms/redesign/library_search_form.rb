class Redesign::LibrarySearchForm
  include ActiveModel::Model

  attr_accessor \
    :keywords,
    :issue_areas,
    :issues,
    :topic_groups,
    :topics,
    :languages,
    :sector_groups,
    :sectors,
    :content_type,
    :sort_field,
    :page,
    :per_page

  Filter = Struct.new(:id, :type, :name, :active)

  def initialize(page = 1, params = {})
    super(params)
    @page = page
    @issue_areas ||= {}
    @issues ||= {}
    @topic_groups ||= {}
    @topics ||= {}
    @languages ||= {}
    @sector_groups ||= {}
    @sectors ||= {}
    @keywords ||= ''
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
        Filter.new(area.id, :issue_area, area.name, issue_areas.has_key?(area.id.to_s)),
        children.map { |issue|
          Filter.new(issue.id, :issue, issue.name, issues.has_key?(issue.id.to_s))
        }
      ]
      end
  end

  def topic_options
    @topic_options ||= Redesign::TopicTree.new.map do |parent, children|
        [
          Filter.new(parent.id, :topic_group, parent.name, topic_groups.has_key?(parent.id.to_s)),
          children.map { |topic|
            Filter.new(topic.id, :topic, topic.name, topics.has_key?(topic.id.to_s))
          }
        ]
      end
  end

  def language_options
    @language_options ||= Language.all.map do |language|
      Filter.new(
        language.id, :language,
        language.name, languages.has_key?(language.id.to_s))
    end
  end

  def sector_options
    @sector_options ||= Redesign::SectorTree.new.map do |parent, children|
      [
        Filter.new(parent.id, :sector_group, parent.name, sector_groups.has_key?(parent.id.to_s)),
        children.map { |sector|
          Filter.new(sector.id, :sector, sector.name, sectors.has_key?(sector.id.to_s))
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

    language_ids = languages.keys.map &:to_i
    if language_ids.any?
      options[:language_ids] = language_ids
    end

    if content_type.present?
      options[:content_type] = content_type.to_i
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

  private

  def add_issue_options(options)
    ids = Set.new
    area_ids = issue_areas.keys.map(&:to_i)
    areas = Issue.includes(:children).find(area_ids)
    areas.each do |area|
      if area.children.any?
        area.children.each do |issue|
          ids << issue.id
        end
      else
        ids << area.id
      end
    end

    issues.keys.each do |id|
      ids << id.to_i
    end

    if ids.any?
      options[:issue_ids] = ids.to_a
    end
  end

  def add_topic_options(options)
    ids = Set.new

    # handle groups
    parent_ids = topic_groups.keys.map(&:to_i)
    parents = Topic.includes(:children).find(parent_ids)
    parents.each do |parent|
      if parent.children.any?
        parent.children.each do |topic|
          ids << topic.id
        end
      else
        ids << parent.id
      end
    end

    # handle individual items
    topics.keys.each do |id|
      ids << id.to_i
    end

    if ids.any?
      options[:topic_ids] = ids.to_a
    end
  end

  def add_sector_options(options)
    ids = Set.new

    parent_ids = sector_groups.keys.map(&:to_i)
    parents = Sector.includes(:children).find(parent_ids)
    parents.each do |parent|
      if parent.children.any?
        parent.children.each do |sector|
          ids << sector.id
        end
      else
        ids << parent.id
      end
    end

    sectors.keys.each do |id|
      ids << id.to_i
    end

    if ids.any?
      options[:sector_ids] = ids.to_a
    end

  end

end
