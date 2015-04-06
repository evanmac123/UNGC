class LandingPage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def tiles
    @data[:tiles] || []
  end
end

