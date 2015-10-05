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

  def contact
    c = headline.try(:contact)
    return {} unless c
    {
      photo: c.image,
      name: c.full_name_with_title,
      title: c.job_title,
      email: c.email,
      phone: c.phone
    }
  end

  def calls_to_action
    return [] if call_to_action_label.nil?
    [{
      label: call_to_action_label,
      url: call_to_action_url,
      external: true
    }]
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
