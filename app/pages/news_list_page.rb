class NewsListPage < ContainerPage
  attr_reader :page, :per_page

  def initialize(container, payload, opts={})
    super(container, payload)
    @page = opts[:page] || 1
    @per_page = 5
  end

  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def news
    news = OpenStruct.new({
      title: "Press Releases",
      other: other
    })
    news
  end

  def other
    Headline.order('published_on desc').paginate(page: page, per_page: per_page)
  end

end

