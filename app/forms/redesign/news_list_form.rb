class Redesign::NewsListForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 5
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []
  attribute :countries,   Array[Integer], default: []
  attribute :start_date,  Date
  attribute :end_date,    Date

  def issue_filter
    IssueFilter.new(issues)
  end

  def topic_filter
    TopicFilter.new(topics)
  end

  def country_filter
    CountryFilter.new(countries)
  end

  def execute
    headlines = Headline.order('published_on desc')

    if countries.any?
      headlines = headlines.where('headlines.country_id in (?)', countries)
    end

    if issues.any?
      headlines = headlines.joins(taggings: [:issue]).where('issue_id in (?)', issues)
    end

    if topics.any?
      headlines = headlines.joins(taggings: [:topic]).where('topic_id in (?)', issues)
    end

    case
    when start_date.present? && end_date.present?
      headlines = headlines.where(created_at: start_date..end_date)
    when start_date.present?
      headlines = headlines.where('created_at > ?', start_date)
    when end_date.present?
      headlines = headlines.where('created_at < ?', end_date)
    end

    headlines.paginate(page: page, per_page: per_page)
  end

end
