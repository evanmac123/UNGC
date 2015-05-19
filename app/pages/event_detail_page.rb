class EventDetailPage < SimpleDelegator
  class EventDateFormatter
    attr_reader :event

    def initialize(event)
      @event = event
    end

    def dates
      if event.is_all_day?
        all_day_date
      else
        date_with_time
      end
    end

    def date_with_time
      if is_same_day?
        "#{event.starts_at.iso8601}"
      else
        "#{event.starts_at.iso8601}-#{event.ends_at.iso8601}"
      end
    end

    def all_day_date
      if is_same_day?
        "#{event.start_date}"
      else
        "#{event.start_date}-#{event.end_date}"
      end
    end

    def is_same_day?
      event.starts_at.to_date == event.ends_at.to_date
    end

    def start_date
      event.starts_at.to_date.strftime("%d %b")
    end

    def end_date
      event.starts_at.to_date.strftime("%d %b")
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
      show_section_nav: true
    }
  end

  def dates
    EventDateFormatter.new(event).dates
  end

  def meta_title
    event.title
  end

  def meta_description
  end

  def meta_keywords
  end

  def location
    full_location
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
    } if call_to_action_1_label
    c << {
      label: call_to_action_2_label,
      url: call_to_action_2_url,
      external: true
    } if call_to_action_2_label
    c
  end

  private

    def event
      __getobj__
    end
end

