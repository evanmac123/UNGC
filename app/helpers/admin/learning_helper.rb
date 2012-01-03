module Admin::LearningHelper
  def event_type_options
    [['All', '']] + LocalNetworkEvent::TYPES.map { |pair| [pair.last, pair.first.to_s] }
  end

  def issue_area_options
    [['All', '']] + LocalNetworkEvent.principle_areas.map { |p| [p.name, p.id.to_s] }
  end

  def region_options
    [['All', '']] + Country::REGIONS.invert.to_a.map { |pair| pair.map(&:to_s) }
  end

  def local_network_options
    [['All', '']] + LocalNetwork.all.map { |n| [n.name, n.id.to_s] }
  end

  def refine_search_button
    link_to 'Refine search', admin_learning_path(:local_network_event_search => params[:local_network_event_search]), :class => 'edit_page_large'
  end

  def new_search_button
    link_to 'New search', admin_learning_path, :class => 'search_large'
  end

  def local_network_region_js
    regions = {}

    Country.all.each do |country|
      if country.local_network_id
        regions[country.region] ||= []
        regions[country.region] << country.local_network_id.to_s
      end
    end

    content_tag :script, "var LocalNetworkRegions = #{regions.to_json};", :type => "text/javascript"
  end
end

def issues_covered(event)
  issues = ''
  event.principles.each do |issue|
    issues += content_tag :li, '&nbsp;', :class => Principle::TYPE_NAMES.key(issue.name), :title => issue.name
  end
  content_tag :ul, issues, :class => 'issues_covered'
end
