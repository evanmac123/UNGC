class LandingPage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def tiles
    @data[:tiles] || []
  end

  def section_nav
    return Components::SectionNav.new(container)
  end
end

