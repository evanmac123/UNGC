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
    :page

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
    @issue_options ||= Issue.where(type: nil)
      .includes(:issue_area)
      .select([:id, :issue_area_id, :name])
      .group(:issue_area_id, :id)
      .group_by do |issue|
        area = issue.issue_area
        Filter.new(area.id, :issue_area, area.name, issue_areas.has_key?(area.id.to_s))
      end
      .map do |group_name, values|
        [group_name, values.map { |issue|
          Filter.new(
            issue.id, :issue,
            issue.name, issues.has_key?(issue.id.to_s))
        }]
      end
  end

  def topic_options
    @topic_options ||= Topic.where.not(parent_id: nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by do |topic|
        parent = topic.parent
        Filter.new(parent.id, :topic_group, parent.name, topic_groups.has_key?(parent.id.to_s))
      end
      .map do |group_name, values|
        [group_name, values.map {|topic|
          Filter.new(
            topic.id, :topic,
            topic.name, topics.has_key?(topic.id.to_s))
        }]
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
    @sector_options ||= Sector.where.not(parent_id:nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by do |sector|
        parent = sector.parent
        Filter.new(parent.id, :sector_group, parent.name, sector_groups.has_key?(parent.id.to_s))
      end
      .map do |group_name, values|
        [group_name, values.map {|sector|
          Filter.new(sector.id, :sector, sector.name, sectors.has_key?(sector.id.to_s))
        }]
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

    issue_area_ids = issue_areas.keys.map &:to_i
    if issue_area_ids.any?
      options[:issue_area_ids] = issue_area_ids
    end

    issue_ids = issues.keys.map &:to_i
    if issue_ids.any?
      options[:issue_ids] = issue_ids
    end

    topic_group_ids = topic_groups.keys.map &:to_i
    if topic_group_ids.any?
      options[:topic_group_ids] = topic_group_ids
    end

    topic_ids = topics.keys.map &:to_i
    if topic_ids.any?
      options[:topic_ids] = topic_ids
    end

    language_ids = languages.keys.map &:to_i
    if language_ids.any?
      options[:language_ids] = language_ids
    end

    sector_group_ids = sector_groups.keys.map &:to_i
    if sector_group_ids.any?
      options[:sector_group_ids] = sector_group_ids
    end

    sector_ids = sectors.keys.map &:to_i
    if sector_ids.any?
      options[:sector_ids] = sector_ids
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
      page: self.page || 1,
      per_page: 10,
      order: order,
      star: true,
      with: options
    }
  end

end
