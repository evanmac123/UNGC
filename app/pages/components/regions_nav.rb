class Components::RegionsNav
  include Enumerable

  def regions
    LocalNetwork.joins(:countries).select('local_networks.*, countries.region as r').distinct('local_networks.id').group_by(&:r)
  end

  def each(&block)
    regions.each do |k,v|
      block.call(RegionNav.new(k),v)
    end
  end

  class RegionNav < SimpleDelegator

    def name
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

    def region
      __getobj__
    end
  end
end
