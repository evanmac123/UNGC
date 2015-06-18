class NewsShowPage < SimpleDelegator

  attr_reader :container

  def initialize(container, headline)
    super(headline)
    @container = container
  end

  def section_nav
    return Components::SectionNav.new(container)
  end

  def hero
    {
      title: {
        title1: 'News'
      },
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/c0/c0ce13d6a6821001ec22702d494f6f815182f19e---press_release.jpg',
      size: 'small',
      show_section_nav: true
    }
  end

  def meta_title
    headline.title
  end

  def meta_description
  end

  def meta_keywords
  end

  private

    def headline
      __getobj__
    end
end
