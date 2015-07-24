class NewsListForm < Redesign::FilterableForm
  include Virtus.model
  include Redesign::FilterMacros

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 5
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []
  attribute :countries,   Array[Integer], default: []
  attribute :types,       Array[Integer], default: []
  attribute :start_date,  Date
  attribute :end_date,    Date

  filter :issue
  filter :topic
  filter :country
  filter :headline_type, selected: :types

  def execute
    Headline.search '', options
  end

  private

  def facets
    Headline.facets '', all_facets: true
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
      Date.today
    end
    date.to_datetime.end_of_day.to_i
  end

end
