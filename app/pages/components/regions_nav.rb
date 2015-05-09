class Components::RegionsNav
  include Enumerable

  def regions
    LocalNetwork.joins(:countries).select('local_networks.*, countries.region as r').distinct('local_networks.id').group_by(&:r)
  end

  def each(&block)
    regions.sort.each do |k,v|
      block.call(RegionNav.new(k),v)
    end
  end

  class RegionNav < SimpleDelegator

    def name
      region_names = {
        'africa'            => 'Africa',
        'asia'              => 'Asia',
        'europe'            => 'Europe',
        'latin_america'     => 'Latin America &amp; Caribbean',
        'mena'              => 'MENA',
        'northern_america'  => 'North America',
        'oceania'           => 'Oceania',
      }

      region_names[region] || ''
    end

    def region_param
      region_params = {
        'africa'            => 'africa',
        'asia'              => 'asia',
        'europe'            => 'europe',
        'latin_america'     => 'latin-america',
        'mena'              => 'mena',
        'northern_america'  => 'north-america',
        'oceania'           => 'oceania',
      }
      region_params[region]
    end

    def url
      "/engage-locally/#{region_param}"
    end

    def region
      __getobj__
    end
  end
end
