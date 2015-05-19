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
      show_section_nav: true
    }
  end

  def meta_title
    event.title
  end

  def meta_description
  end

  def meta_keywords
  end

  private

    def event
      __getobj__
    end
end

