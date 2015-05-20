class EventPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def events
    @results.map { |e| EventBox.new(e) }
  end

  class EventBox < SimpleDelegator
    def tag
      if event.is_online?
        'Online'
      elsif event.is_invitation_only?
        'Invitation'
      else
        'Open'
      end
    end

    def event
      __getobj__
    end
  end

end


