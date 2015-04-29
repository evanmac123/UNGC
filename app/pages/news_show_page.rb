class NewsShowPage

  attr_reader :headline

  def initialize(headline)
    @headline = headline
  end

  def hero
    {
      title: {
        title1: 'News'
      },
      size: 'small',
      show_section_nav: false
    }
  end

  def title
    headline.title
  end

  def description
    headline.description
  end

  def location
    headline.location + ', ' + headline.country.name
  end

  def meta_title
    headline.title
  end

  def meta_description
  end

  def meta_keywords
  end
end
