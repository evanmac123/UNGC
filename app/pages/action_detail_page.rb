class ActionDetailPage < ContainerPage
  def hero
    @data[:hero] || {}
  end

  def main_content_section
    data = @data[:action_detail_block] || {}
    data
  end

  def sidebar_widgets
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:calls_to_action] = Components::CallsToAction.new(@data).data

    widgets[:links_lists] = Components::LinksLists.new(@data).data

    widgets
  end

  def related_content
    Components::RelatedContent.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data).data
  end

  def partners
    partners = [
      {
        name: "Unicef",
        logo: "http://www.logospike.com/wp-content/uploads/2014/11/Unicef_logo-5.png"
      },
      {
        name: "International Trade Centre",
        logo: "http://empretecguyana.org/Images/ITC_logo.png"
      },
      {
        name: "Food and Agriculture Organization of the United Nations",
        logo: "http://www.fao.org/fileadmin/templates/faoweb/images/FAO-logo.png"
      },
    ]

    partners.map!{|p| OpenStruct.new(p)}
  end

  def participants
    [
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      },
      {
        name: 'A. Amigos de Silva',
        sector: 'Public Sector',
        country: 'Spain',
        url: ''
      }
    ]
  end
end
