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
