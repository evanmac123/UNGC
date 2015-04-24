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
    Redesign::TopicTree.new.map do |parent, children|
      add_selections(parent, children, selected_topics)
    end
  end

  def issue_options
    Redesign::IssueTree.new.map do |parent, children|
      add_selections(parent, children, selected_issues)
    end
  end

  def sector_options
    Redesign::SectorTree.new.map do |parent, children|
      add_selections(parent, children, selected_sectors)
    end
  end

  private

    def resource
      __getobj__
    end

    def selected_topics
      resource.topics
    end

    def selected_issues
      resource.issues
    end

    def selected_sectors
      resource.sectors
    end

    def add_selections(parent_tag, child_tags, selected)
      selected_ids = selected.pluck(:id)

      filtered_parent_tag = Filter.new(parent_tag, selected_ids.include?(parent_tag.id))

      filtered_child_tags = Array(child_tags).map do |child_tag|
        Filter.new(child_tag, selected_ids.include?(child_tag.id))
      end

      [filtered_parent_tag, filtered_child_tags]
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
