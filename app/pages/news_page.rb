class NewsPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_section_nav: true})
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def news
    news = OpenStruct.new({
      title: "Press Releases",
      featured: {
        url: '',
        title: 'Global Compact LEAD Symposium Imagines the Future Corporation',
        date: '20 November 2014',
        location: 'New York, USA',
        blurb: 'Companies and sustainability experts sketched an outline of The Future Corporation the Global Compact LEAD Symposium.'
      },
      other: [{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      },{
        url: '',
        title: 'UN Global Compact Builds Momentum for Agribusiness and SDGs',
        date: '12 November 2014',
        location: 'New York, USA'
      }]
    })

    news.featured = OpenStruct.new(news.featured)
    news.other.map!{|ni| OpenStruct.new(ni)}

    news
  end

  def sidebar_widgets
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:calls_to_action] = Components::CallsToAction.new(@data).data

    widgets
  end

  def related_contents
    Components::RelatedContents.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

end

