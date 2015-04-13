class AllIssuePage < ContainerPage

  def issues
    Redesign::Container.issue
  end

end
