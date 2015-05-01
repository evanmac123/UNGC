class Redesign::AllOurWorkForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 5
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []

  def issue_filter
    IssueFilter.new(issues)
  end

  def topic_filter
    TopicFilter.new(topics)
  end

  def execute
    containers = Redesign::Container.issue.includes(:public_payload)

    if issues.any?
      containers = containers.joins(taggings: [:issue]).where('issue_id in (?)', issues)
    end

    if topics.any?
      containers = containers.joins(taggings: [:topic]).where('topic_id in (?)', issues)
    end

    containers.paginate(page: page, per_page: per_page)
  end

end
