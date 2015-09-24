class NewsPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def news
    news = OpenStruct.new({
      title: "News Desk",
      featured: featured,
      other: other
    })
    news
  end

  def featured
    scoped.order('published_on desc').limit(1).first
  end

  def other
    scoped.order('published_on desc').offset(1).limit(2)
  end

  def sidebar_widgets
    Components::SidebarWidgets.new(@data)
  end

  def related_contents
    Components::RelatedContents.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

  private

  def scoped
    Headline.approved.includes(:country)
  end

end

