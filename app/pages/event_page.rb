class EventPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    (@data[:hero] || {}).merge({show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def events
    @results.map { |e| EventDetailPage.new(container, e) }
  end
end


