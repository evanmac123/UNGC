class Redesign::EventsListForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []
  attribute :countries,   Array[Integer], default: []
  attribute :types,       Array[String],  default: []
  attribute :start_date,  Date,           default: -> (page, attribute) { Date.today }
  attribute :end_date,    Date

  def filters
    [issue_filter, topic_filter, country_filter, type_filter]
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

  def type_filter
    @type_filter ||= Filters::EventTypeFilter.new(types)
  end

  def execute
    events = Event.approved.includes(:country).order('starts_at asc')

    if countries.any?
      events = events.where('events.country_id in (?)', countries)
    end

    if issues.any?
      ids = issue_filter.effective_selection_set
      events = events.joins(taggings: [:issue]).where('issue_id in (?)', ids)
    end

    if topics.any?
      ids = topic_filter.effective_selection_set
      events = events.joins(taggings: [:topic]).where('topic_id in (?)', ids)
    end

    types.each do |type|
      case type
      when 'online'
        events = events.where(is_online: true)
      when 'in_person'
        events = events.where(is_online: false)
      when 'invite_only'
        events = events.where(is_invitation_only: true)
      else
        Rails.logger.warn("Invalid event type: #{type}")
      end
    end

    e = Event.arel_table
    case
    when start_date.present? && end_date.present?
      events = events.where(
        (e[:starts_at].gteq(start_date).or(e[:ends_at].gteq(start_date)))
        .and(e[:starts_at].lteq(end_date).or(e[:ends_at].lteq(end_date)))
      )
    when start_date.present?
      events = events.where(e[:starts_at].gteq(start_date).or(e[:ends_at].gteq(start_date)))
    when end_date.present?
      events = events.where(e[:starts_at].lteq(end_date).or(e[:ends_at].lteq(end_date)))
    end

    events.distinct('events.id').paginate(page: page, per_page: per_page)
  end

end
