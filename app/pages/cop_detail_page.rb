class CopDetailPage

  attr_reader :container, :communication

  def initialize(container, communication)
    @container = container
    @communication = communication
  end

  def hero
    {size: 'small'}
    {
      title: {
        title1: communication.full_name
      },
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/2c/2cd2286d7705dc60df73e605229437dd4a6c3a63---sky.jpg',
      size: 'small',
      show_section_nav: true
    }
  end

  def meta_title
    "#{communication.organization_name} - #{communication.title}"
  end

  def meta_description
  end

  def section_nav
    return Components::SectionNav.new(container)
  end
end
