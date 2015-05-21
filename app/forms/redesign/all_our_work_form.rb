class Redesign::AllOurWorkForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []

  def filters
    [issue_filter, topic_filter]
  end

  def issue_filter
    @issue_filter ||= Filters::IssueFilter.new(issues, issues)
  end

  def topic_filter
    @topic_filter ||= Filters::TopicFilter.new(topics, topics)
  end

  def execute
    containers = Redesign::Container.issue.includes(:public_payload)

    if issues.any?
      ids = issue_filter.effective_selection_set
      containers = containers.joins(taggings: [:issue]).where('issue_id in (?)', ids)
    end

    if topics.any?
      ids = topic_filter.effective_selection_set
      containers = containers.joins(taggings: [:topic]).where('topic_id in (?)', ids)
    end

    containers.paginate(page: page, per_page: per_page)
  end

end
