class TaggingPresenter < SimpleDelegator

  # topics, issue and sectors all have N+1 issues here
  # taggable.sectors is not using the eager loading we've defined
  # TODO find a fix.

  def initialize(taggable)
    super(taggable)#.includes(:taggings))
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

    def taggable
      __getobj__
    end

    def selected_topics
      taggable.topics
    end

    def selected_issues
      taggable.issues
    end

    def selected_sectors
      taggable.sectors
    end

    def add_selections(parent, children, type, selected)
      selected_ids = selected.pluck(:id)

      parent_option = FilterOption.new(parent.id, parent.name, type, selected_ids.include?(parent.id))

      child_options = Array(children).map do |child|
        FilterOption.new(child.id, child.name, type, selected_ids.include?(child.id))
      end

      [parent_option, child_options]
    end
end
