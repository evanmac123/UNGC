class AllIssuePage < ContainerPage

  def hero
    {
      title: {
        title1: 'Issues'
      }
    }
  end

  def issues
    Redesign::Container.issue.includes(:public_payload).map { |c| Components::ContentBox.new(c) }
  end

end
