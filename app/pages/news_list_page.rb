class NewsListPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    (@data[:hero] || {}).reverse_merge({
      size: 'small'
    })
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def news
    OpenStruct.new(
      title: "Press Releases",
      other: results
    )
  end

  def last_updated_at
    results.first.approved_at
  end
end
