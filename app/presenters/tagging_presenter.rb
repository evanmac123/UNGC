class TaggingPresenter < SimpleDelegator

  # topics, issue and sectors all have N+1 issues here
  # taggable.sectors is not using the eager loading we've defined
  # TODO find a fix.

  def initialize(taggable)
    super(taggable)#.includes(:taggings))
  end

  def topic_options
    Filters::TopicFilter.new(selected_topic_ids, selected_topic_ids).options
  end

  def issue_options
    Filters::IssueFilter.new(selected_issue_ids, selected_issue_ids).options
  end

  def sector_options
    Filters::SectorFilter.new(selected_sector_ids, selected_sector_ids).options
  end

  private

    def taggable
      __getobj__
    end

    def selected_topic_ids
      taggable.topic_ids
    end

    def selected_issue_ids
      taggable.issue_ids
    end

    def selected_sector_ids
      taggable.sector_ids
    end
end
