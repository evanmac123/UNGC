class ActionPlatform::PlatformPage

  attr_reader :platform

  def initialize(platform)
    @platform = platform
  end

  def meta_title
   platform.name
  end

  def title
   platform.name
  end

  def meta_description
    # TODO: might need this later
  end

  def description
   platform.description || ""
  end

  def hero
    {
      title: {
        title1: platform.name,
      },
      image: 'https://d306pr3pise04h.cloudfront.net/uploads/b1/b1757c442f979297b1e13aa44dcaf58da156106a---forest.jpg',
      size: 'small',
      theme: 'light',
      show_section_nav: false
    }
  end

end
