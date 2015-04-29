class EngageLocallyPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small', show_regions_nav: true})
  end

  def regions_nav
    LocalNetwork.joins(:countries).select('local_networks.*, countries.region as r').distinct('local_networks.id').group_by(&:r)
  end

  def main_content_section
    @data[:content_block] || {}
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

  def region_name(region)
    region_names = {
      'europe'            => 'Europe',
      'latin_america'     => 'Latin America &amp; Caribbean',
      'oceania'           => 'Oceania',
      'asia'              => 'Asia',
      'northern_america'  => 'North America',
      'africa'            => 'Africa',
      'mena'              => 'MENA'
    }

    region_names[region] || ''
  end
end
