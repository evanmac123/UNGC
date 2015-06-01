class Redesign::NewsListForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 5
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []
  attribute :countries,   Array[Integer], default: []
  attribute :start_date,  Date
  attribute :end_date,    Date

  def filters
    [issue_filter, topic_filter, country_filter]
  end

  def issue_filter
    @issue_filter ||= Filters::IssueFilter.new(issues, issues)
  end

  def topic_filter
    @topic_filter ||= Filters::TopicFilter.new(topics, topics)
  end

  def country_filter
    @country_filter ||= Filters::CountryFilter.new(countries)
  end

  def execute
    headlines = Headline.approved.includes(:country).order('published_on desc')

    if countries.any?
      headlines = headlines.where('headlines.country_id in (?)', countries)
    end

    if issues.any?
      ids = issue_filter.effective_selection_set
      headlines = headlines.joins(taggings: [:issue]).where('issue_id in (?)', ids)
    end

    if topics.any?
      ids = topic_filter.effective_selection_set
      headlines = headlines.joins(taggings: [:topic]).where('topic_id in (?)', ids)
    end

    case
    when start_date.present? && end_date.present?
      headlines = headlines.where(created_at: start_date..end_date)
    when start_date.present?
      headlines = headlines.where('created_at > ?', start_date)
    when end_date.present?
      headlines = headlines.where('created_at < ?', end_date)
    end

    headlines.distinct('headlines.id').paginate(page: page, per_page: per_page)
  end

end
