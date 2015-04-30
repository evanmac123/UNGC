class LocalNetworkPage < SimpleDelegator

  def regions_nav
    return Components::RegionsNav.new
  end

  def hero
    {
      title: {
        title1: 'Act Globally',
        title2: 'Engage Locally'
      },
      size: 'small',
      show_regions_nav: true
    }
  end

  def meta_title
    local_network.name
  end

  def meta_description
  end

  def meta_keywords
  end

  private

    def local_network
      __getobj__
    end
end

