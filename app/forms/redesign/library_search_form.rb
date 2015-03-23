class Redesign::LibrarySearchForm
  include ActiveModel::Model

  attr_accessor \
    :keywords,
    :issues,
    :topics,
    :languages,
    :sectors,
    :content_type,
    :sort_field,
    :page

  Filter = Struct.new(:id, :type, :name, :active)

  def initialize(page = 1, params = {})
    super(params)
    @page = page
    @issues ||= {}
    @topics ||= {}
    @languages ||= {}
    @sectors ||= {}
    @keywords ||= ''
  end

  def active_filters
    issues = issue_options.select(&:active)
    topics = topic_options.select(&:active)
    languages = language_options.select(&:active)
    sectors = sector_options.flat_map do |group, sectors|
      sectors.select(&:active)
    end
    [issues, topics, languages, sectors].flatten
  end

  def issue_options
    # grouped arrays [[name, [filters]], ...]
    @issue_options ||= Issue.all.map do |issue|
      Filter.new(
        issue.id, :issue,
        issue.name, issues.has_key?(issue.id.to_s))
    end
  end

  def topic_options
    @topic_options ||= Topic.all.map do |topic|
      Filter.new(
        topic.id, :topic,
        topic.name, topics.has_key?(topic.id.to_s))
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
    # grouped arrays [[name, [filters]], ...]
    @sector_options ||= Sector.where.not(parent_id:nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by { |s| s.parent.name }
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

    principle_ids = [issues.keys, topics.keys].flatten.map &:to_i
    if principle_ids.any?
      options[:principle_ids] = principle_ids
    end

    language_ids = languages.keys.map &:to_i
    if language_ids.any?
      options[:language_ids] = language_ids
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
