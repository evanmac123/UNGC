class ActionPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    @data[:hero] || {}
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def actions
    results.map { |c| Components::ContentBox.new(c) }
  end

end
