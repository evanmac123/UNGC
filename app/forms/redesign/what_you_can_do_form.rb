class Redesign::WhatYouCanDoForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []

  attr_reader :seed
  def initialize(params, seed)
    super(params)
    @seed = seed
  end

  def filters
    [issue_filter, topic_filter]
  end

  def issue_filter
    excluded = [
      "Persons with Disabilities",
      "Poverty",
      "Women's Empowerment"
    ]
    @issue_filter ||= Filters::IssueFilter.new(issues, issues, excluded: excluded)
  end

  def topic_filter
    excluded = [
      "Millennium Development Goals",
      "Communication on Engagement",
      "Social Enterprise"
    ]
    @topic_filter ||= Filters::TopicFilter.new(topics, topics, excluded: excluded)
  end

  def execute
    containers = Redesign::Container.action.includes(:public_payload)

    if issues.any?
      ids = issue_filter.effective_selection_set
      containers = containers.joins(taggings: [:issue]).where('issue_id in (?)', ids)
    end

    if topics.any?
      ids = topic_filter.effective_selection_set
      containers = containers.joins(taggings: [:topic]).where('topic_id in (?)', ids)
    end

    containers.
      distinct('containers.id').
      order("rand(#{seed})").
      paginate(page: page, per_page: per_page)
  end

end
