class Redesign::EventsListForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :start_date,  Date,           default: -> (page, attribute) { Date.today }
  attribute :end_date,    Date

  def execute
    events = Event.approved.includes(:country).order('starts_at asc')

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
