class AllOurWorkPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    {
      title: {
        title1: 'All Issues'
      }
    }
  end

  def issues
    results.map { |c| Components::ContentBox.new(c) }
  end

end
