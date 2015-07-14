class EventDetailPage < SimpleDelegator

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
    EventDetailPages::DateFormatter.new(event).date
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


  Tab = Struct.new(:title, :description, :sponsors) do
    def slug
      @slug ||= ActiveSupport::Inflector.parameterize(title)
    end
  end

  def tabs
    t = []
    t << Tab.new('Programme', event.overview_description) if event.overview_description.present?
    t << Tab.new('Media', event.media_description) if event.media_description.present?
    t << Tab.new(event.tab_1_title, event.tab_1_description) if event.tab_1_description.present?
    t << Tab.new(event.tab_2_title, event.tab_2_description) if event.tab_2_description.present?
    t << Tab.new(event.tab_3_title, event.tab_3_description) if event.tab_3_description.present?
    t << Tab.new('Sponsors', event.sponsors_description, event.sponsors) if event.sponsors_description.present? || event.sponsors.present?
    t
  end

  private

  def event
    __getobj__
  end
end
