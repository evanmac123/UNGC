class NewsListForm < FilterableForm
  include Virtus.model
  include FilterMacros

  attribute :page,                          Integer,        default: 1
  attribute :per_page,                      Integer,        default: 5
  attribute :issues,                        Array[Integer], default: []
  attribute :topics,                        Array[Integer], default: []
  attribute :countries,                     Array[Integer], default: []
  attribute :types,                         Array[Integer], default: []
  attribute :sustainable_development_goals, Array[Integer], default: []
  attribute :start_date,                    Date
  attribute :end_date,                      Date

  filter :issue
  filter :topic
  filter :sustainable_development_goal
  filter :country
  filter :headline_type, selected: :types

  attr_writer :search_scope

  def execute
    search_scope.search '', options
  end

  def start_date=(value)
    super(parse_date(value))
  end

  def end_date=(value)
    super(parse_date(value))
  end

  private

  def parse_date(input)
    sanitized = sanitize(input)
    if sanitized.present?
      Date.parse(sanitized)
    end
  rescue ArgumentError
    nil
  end

  def sanitize(input)
    if input.respond_to?(:gsub)
      input.gsub(/[^\d-]/, "")
    else
      input
    end
  end

  def options
    {
      page: page,
      per_page: per_page,
      order: 'published_on desc',
      with: reject_blanks(
        issue_ids: issue_filter.effective_selection_set,
        topic_ids: topic_filter.effective_selection_set,
        country_id: countries,
        headline_type: types,
        sustainable_development_goal_ids: sustainable_development_goals,
        created_at: date_range,
      ),
    }
  end

  def date_range
    if start_date.present? || end_date.present?
      start_of_first_date..end_of_last_date
    end
  end

  def start_of_first_date
    if start_date.present?
      start_date.to_datetime.beginning_of_day.to_i
    else
      0
    end
  end

  def end_of_last_date
    date = if end_date.present?
      end_date
    else
      Date.current
    end
    date.to_datetime.end_of_day.to_i
  end

  def facets
    search_scope.facets '', all_facets: true
  end

  def search_scope
    @search_scope ||= Headline
  end
end
