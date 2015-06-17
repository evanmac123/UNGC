class EngageLocallyRegionPage < EngageLocallyPage
  attr_reader :region

  def initialize(container, payload, region = nil)
    super(container, payload)
    @region = Region.find_by(param: region) if region
  end

  def networks
    return LocalNetwork.none unless region
    LocalNetwork.
      joins(:countries).
      where('countries.region = ?', region.name).
      distinct('local_networks.id')
  end
end
