class Redesign::EventsListForm < Redesign::FilterableForm
  include Virtus.model
  include Redesign::FilterMacros

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :start_date,  Date,           default: -> (page, attribute) { Date.today }
  attribute :end_date,    Date

  # http://stackoverflow.com/questions/535721/ruby-max-integer
  FIXNUM_MAX = (2**(0.size * 8 -2) -1)

  def execute
    Event.search '', options
  end

  def options
    {
      select: date_range_clause,
      with: {in_date_range: true}
    }
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
    if start_date.present?
      start_date.to_datetime.beginning_of_day.to_i
    else
      0
    end
  end

  def end_of_last_date
    if end_date.present?
      end_date.to_datetime.end_of_day.to_i
    else
      FIXNUM_MAX
    end
  end

end
