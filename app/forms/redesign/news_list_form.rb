class Redesign::NewsListForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 5
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []
  attribute :countries,   Array[Integer], default: []
  attribute :start_date,  Date
  attribute :end_date,    Date

  def issue_options
    Redesign::IssueTree.new.map do |parent, children|
      parent_option = FilterOption.new(parent.id, parent.name, :issue, issues.include?(parent.id))
      child_options = children.map do |child|
        FilterOption.new(child.id, child.name, :issue, issues.include?(child.id))
      end
      [parent_option, child_options]
    end
  end

  def topic_options
    Redesign::TopicTree.new.map do |parent, children|
      parent_option = FilterOption.new(parent.id, parent.name, :topic, topics.include?(parent.id))
      child_options = children.map do |child|
        FilterOption.new(child.id, child.name, :topic, topics.include?(child.id))
      end
      [parent_option, child_options]
    end
  end

  def country_options
    Country.pluck(:id, :name).map do |id, name|
      FilterOption.new(id, name, :country, countries.include?(id))
    end
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
