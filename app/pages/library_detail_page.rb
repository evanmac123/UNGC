class LibraryDetailPage
  attr_reader :container, :resource

  def initialize(container, resource)
    @container = container
    @resource = resource
  end

  def hero
    {size: 'small'}
    {
      title: {
        title1: 'Explore Our Library'
      },
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/9e/9e9d00411ce7c64d9e8ad95595342210068a29d0---library.jpg',
      size: 'small',
      show_section_nav: false
    }
  end

  def meta_title
    resource.title
  end

  def meta_description
  end

  def section_nav
    return Components::SectionNav.new(container)
  end
end
