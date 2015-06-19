class EngageLocallyRegionPage < EngageLocallyPage
  attr_reader :region

  def initialize(container, payload, region)
    super(container, payload)
    @region = Region.find_by(param: region)
  end

  def networks
    LocalNetwork.
      joins(:countries).
      where('countries.region = ?', region.name).
      distinct('local_networks.id')
  end
end
