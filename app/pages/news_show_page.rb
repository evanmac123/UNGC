class NewsShowPage < SimpleDelegator

  def initialize(headline)
    super(headline)
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
