class EngageLocallyPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_regions_nav: true})
  end

  def regions_nav
    Components::RegionsNav.new
  end

  def main_content_section
    @data[:content_block] || {}
  end

  def main_content_links
    [{
      links: [{
        label: 'Find out more about local networks',
        url: ''
      },{
        label: 'Manage your network',
        url: ''
      }]
    }]
  end

  def sidebar_widgets
    Components::SidebarWidgets.new(@data)
  end

  def related_contents
    Components::RelatedContents.new(@data)
  end

  def resources
    Components::Resources.new(@data).data
  end

  def events
    Components::Events.new(@data).data
  end

  def news
    Components::News.new(@data)
  end
end