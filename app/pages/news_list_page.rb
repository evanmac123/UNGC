class NewsListPage < ContainerPage
  attr_reader :results

  def initialize(container, payload, results)
    super(container, payload)
    @results = results
  end

  def hero
    (@data[:hero] || {}).reverse_merge({
      title: {
        title1: 'Press Releases'
      },
      size: 'small',
      show_section_nav: true
    })
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def news
    news = OpenStruct.new({
      title: "Press Releases",
      other: results
    })
    news
  end
end
