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
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/02/029f94ffc19f95c80a441f47697f54055cda1b25---library.jpg',
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
