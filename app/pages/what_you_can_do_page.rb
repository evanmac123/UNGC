class WhatYouCanDoPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    {
      title: {
        title1: 'What you can do'
      }
    }
  end

  def actions
    results.map { |c| Components::ContentBox.new(c) }
  end

end

