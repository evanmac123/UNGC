class EventDetailPages::DateFormatter
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def date
    OpenStruct.new({
      iso: _iso,
      string: _string,
      string_with_time: _string_with_time
    })
  end

  private

  def _string
    _is_same_day? ? _start_date.strftime(_date_format) : "#{_start_date.strftime(_date_format)}-#{_end_date.strftime(_date_format)}"
  end

  def _string_with_time
    _format = event.is_all_day? ? _date_format : "#{_date_format} at #{_hour_format}"
    _is_same_day? ? _start_date.strftime(_format) : "#{_start_date.strftime(_format)}-#{_end_date.strftime(_format)}"
  end

  def _iso
    _is_same_day? ? "#{_start_date.iso8601}" : "#{_start_date.iso8601}-#{_end_date.iso8601}"
  end

  def _is_same_day?
    event.starts_at.to_date == event.ends_at.to_date
  end

  def _date_format
    "%b %-d, %Y"
  end

  def _hour_format
    "%I:%M %P"
  end

  def _start_date
    event.is_all_day? ? event.starts_at.to_date : event.starts_at
  end

  def _end_date
    event.is_all_day? ? event.ends_at.to_date : event.ends_at
  end
end
