class EventsListForm < FilterableForm
  include Virtus.model
  include FilterMacros

  attribute :page,                          Integer,        default: 1
  attribute :per_page,                      Integer,        default: 12
  attribute :issues,                        Array[Integer], default: []
  attribute :topics,                        Array[Integer], default: []
  attribute :countries,                     Array[Integer], default: []
  attribute :types,                         Array[String],  default: []
  attribute :sustainable_development_goals, Array[Integer], default: []
  attribute :start_date,                    Date,           default: -> (page, attribute) { Date.current }
  attribute :end_date,                      Date

  filter :issue
  filter :topic
  filter :sustainable_development_goal
  filter :country
  filter :event_type

  attr_writer :search_scope

  # http://stackoverflow.com/questions/535721/ruby-max-integer
  FIXNUM_MAX = (2**(0.size * 8 -2) -1)

  def execute
    search_scope.search '', options
  end

  def event_type_filter
    materialized_filters[:event_type]
  end

  def create_event_type_filter(options)
    filter = Filters::EventTypeFilter.new(types)

    EventFacetFilter.new(filter, facets.to_h)
  end

  private

  def options
    {
      page: page,
      per_page: per_page,
      order: 'starts_at asc',
      select: date_range_clause,
      with: reject_blanks(
        issue_ids: issue_filter.effective_selection_set,
        topic_ids: topic_filter.effective_selection_set,
        sustainable_development_goal_ids: sustainable_development_goals,
        country_id: countries,
        in_date_range: true,
        is_online: online?,
        is_invitation_only: invite_only?,
        is_academy: academy?
      )
    }
  end

  def online?
    types.map do |v|
      case v
      when 'online'
        true
      when 'in_person'
        false
      end
    end.compact
  end

  def invite_only?
    types.map do |v|
      true if v == 'invite_only'
    end.compact
  end

  def academy?
    types.map do |v|
      true if v == 'academy'
    end.compact
  end

  def date_range_clause
    [
      "*, ",
      "(starts_at >= #{start_of_first_date} and starts_at <= #{end_of_last_date})",
      " or ",
      "(ends_at >= #{start_of_first_date} and ends_at <= #{end_of_last_date})",
      " as in_date_range"
    ].join
  end

  def start_of_first_date
    start_date.to_datetime.beginning_of_day.to_i
  rescue
    0
  end

  def end_of_last_date
    if end_date.present?
      end_date.to_datetime.end_of_day.to_i
    else
      FIXNUM_MAX
    end
  end

  def facets
    search_scope.facets('', all_facets: true)
  end

  def search_scope
    @search_scope ||= Event
  end

  class EventFacetFilter < Filters::FacetFilter

    def include?(option)
      case option.id
      when 'online'
        online_facets.has_key? 1
      when 'in_person'
        online_facets.has_key? 0
      when 'invite_only'
        invite_facets.has_key? 1
      when 'academy'
        academy_facets.has_key? 1
      else
        raise "unexpected option.id: #{option.id}"
      end
    end

    private

    def online_facets
      @online_facets ||= facets.fetch(:is_online, {})
    end

    def invite_facets
      @invite_facets ||= facets.fetch(:is_invitation_only, {})
    end

    def academy_facets
      @academy_facets ||= facets.fetch(:is_academy, {})
    end

  end

end
