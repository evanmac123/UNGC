class EventDetailPage < SimpleDelegator
  class EventDateFormatter
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

  attr_reader :container

  def initialize(container, event)
    super(event)
    @container = container
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def hero
    {
      title: {
        title1: 'Events'
      },
      size: 'small',
      show_section_nav: true,
      image: event.banner_image.url
    }
  end

  def date
    EventDateFormatter.new(event).date
  end

  def meta_title
    event.title
  end

  def meta_description
  end

  def meta_keywords
  end

  def location
    if is_online?
      'Online'
    else
      full_location
    end
  end

  def contact
    c = event.try(:contact)
    return {} unless c
    {
      photo: c.image,
      name: c.full_name_with_title,
      title: c.job_title,
      email: c.email,
      phone: c.phone
    }
  end

  def calls_to_action
    c = []
    c << {
      label: call_to_action_1_label,
      url: call_to_action_1_url,
      external: true
    } if call_to_action_1_label.present?
    c << {
      label: call_to_action_2_label,
      url: call_to_action_2_url,
      external: true
    } if call_to_action_2_label.present?
    c
  end

  def tag
    if event.is_online?
      'Online'
    elsif event.is_invitation_only?
      'Invitation'
    else
      'Open'
    end
  end

  private

  def event
    __getobj__
  end
end
