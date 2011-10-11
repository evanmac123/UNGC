module Admin::LearningHelper
  def event_type_options
    [['All', '']] + LocalNetworkEvent::TYPES.map { |pair| [pair.last, pair.first.to_s] }
  end

  def issue_area_options
    [['All', '']] + LocalNetworkEvent.principle_areas.map { |p| [p.name, p.id.to_s] }
  end

  def region_options
    [['All', '']] + Country::REGIONS.map { |r| [r, r] }
  end

  def local_network_options
    [['All', '']] + LocalNetwork.all.map { |n| [n.name, n.id.to_s] }
  end

  def new_search_button
    button_to 'New search', :action => 'index', :local_network_event_search => params[:local_network_event_search]
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

