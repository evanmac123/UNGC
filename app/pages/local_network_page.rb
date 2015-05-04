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

  def description
    <<-HTML
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse quam mauris, rutrum eu velit a, scelerisque ornare elit. Pellentesque dictum ipsum lectus, a varius metus faucibus pulvinar. Sed id libero in nunc cursus efficitur. Donec a viverra arcu. Phasellus sit amet rutrum nulla. Ut eget pharetra odio, ac molestie purus. Nam sit amet mollis nunc. Praesent fermentum arcu vitae ligula suscipit molestie. Sed vulputate tincidunt congue. Nam placerat imperdiet velit quis iaculis. Mauris non pretium ante. Morbi pretium lectus eget lorem pharetra facilisis. Nulla lobortis nulla finibus accumsan vulputate. Donec ac diam non dolor pretium fringilla.</p>
    HTML
  end

  def meta_title
    local_network.name
  end

  def meta_description
  end

  def meta_keywords
  end

  def sidebar_widgets
    OpenStruct.new({
      contact: {
        name: 'Some Person',
        title: 'Very Important',
        email: 'important@person.com',
        phone: '+1 (555) imp-rtnt'
      }
    })
  end

  def participants
    OpenStruct.new({
      total: 282,
      list: [{
        sector: 'Support Services',
        url: '',
        count: 20
      }, {
        sector: 'Gas, Water &amp; Multi Utilities',
        url: '',
        count: 18
      }, {
        sector: 'Food Producers',
        url: '',
        count: 14
      }, {
        sector: 'Automobiles',
        url: '',
        count: 13
      }, {
        sector: 'Construction',
        url: '',
        count: 9
      }]
    })
  end

  private

    def local_network
      __getobj__
    end
end

