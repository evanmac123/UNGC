class EngageLocallyPage < ContainerPage
  def hero
    (@data[:hero] || {}).merge({size: 'small'})
  end

  def regions_nav
    grouped_networks = LocalNetwork.joins(:countries).select('local_networks.*, countries.region as r').distinct('local_networks.id').group_by(&:r)
  end

  def main_content_section
    @data[:content_block] || {}
  end

  def sidebar_widgets
    widgets = {}

    widgets[:contact] = Components::Contact.new(@data).data

    widgets[:calls_to_action] = Components::CallsToAction.new(@data).data

    widgets
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
end
