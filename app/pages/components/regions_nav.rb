class Components::RegionsNav
  include Enumerable

  def regions
    LocalNetwork.
      active_networks.
      joins(:countries).
      select('local_networks.*, countries.region as r').
      distinct('local_networks.id').
      group_by(&:r)
  end

  def each(&block)
    regions.sort.each do |k,v|
      block.call(RegionNav.new(k),v)
    end
  end

  class RegionNav < SimpleDelegator

    def name
      Region.find_by(name: region).title
    end

    def region_param
      Region.find_by(name: region).param
    end

    def url
      "/engage-locally/#{region_param}"
    end

    def region
      __getobj__
    end
  end
end
