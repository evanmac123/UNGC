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
        title1: 'Explore our enhanced library'
      },
      size: 'small',
      blurb: 'Designed to help you find the resources you need to take the next step on your sustainability journey.',
      theme: 'dark',
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
