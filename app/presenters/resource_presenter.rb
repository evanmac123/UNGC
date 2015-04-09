class ResourcePresenter < SimpleDelegator

  # topics, issue and sectors all have N+1 issues here
  # resource.sectors is not using the eager loading we've defined
  # TODO find a fix.

  def initialize(resource)
    super(resource)#.includes(:taggings))
  end

  def content_types_for_select
    Resource.content_types.keys.map {|k| [k.humanize.titleize, k]}
  end

  def human_content_type
    if content_type.present?
      content_type.humanize.titleize
    else
      ''
    end
  end

  def topic_options
    Redesign::TopicTree.new.map do |group, items|
      add_selections(group, items, topics)
    end
  end

  def issue_options
    Redesign::IssueTree.new.map do |group, items|
      add_selections(group, items, issues)
    end
  end

  def sector_options
    Redesign::SectorTree.new.map do |group, items|
      add_selections(group, items, sectors)
    end
  end

  private

  def add_selections(group, items, selected)
    selected_ids = selected.pluck(:id)
    children = Array(items).map do |item|
      Filter.new(item, selected_ids.include?(item.id))
    end
    [group, children]
  end

  Filter = Struct.new(:model, :selected?) do

    def id
      model.id
    end

    def name
      model.name
    end

  end

end
