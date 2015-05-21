class ResourcePresenter < SimpleDelegator

  # topics, issue and sectors all have N+1 issues here
  # resource.sectors is not using the eager loading we've defined
  # TODO find a fix.

  def initialize(resource)
    super(resource)#.includes(:taggings))
  end

  def content_types_for_select
    Resource.content_types.keys.map {|k| [I18n.t("resources.types.#{k}"), k]}
  end

  def human_content_type
    if content_type.present?
      I18n.t("resources.types.#{content_type}")
    else
      ''
    end
  end

  def topic_options
    Redesign::TopicTree.new.map do |parent, children|
      add_selections(parent, children, :topic, selected_topics)
    end
  end

  def issue_options
    Redesign::IssueTree.new.map do |parent, children|
      add_selections(parent, children, :issue, selected_issues)
    end
  end

  def sector_options
    Redesign::SectorTree.new.map do |parent, children|
      add_selections(parent, children, :sector, selected_sectors)
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

    def add_selections(parent, children, type, selected)
      selected_ids = selected.pluck(:id)

      parent_options = FilterOption.new(parent.id, parent.name, type, selected_ids.include?(parent.id))

      child_options = Array(children).map do |child|
        FilterOption.new(child.id, child.name, type, selected_ids.include?(child.id))
      end

      [parent_options, child_options]
    end
end
