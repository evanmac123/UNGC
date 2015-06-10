class Redesign::NetworksController < Redesign::ApplicationController
  def show
    name = params[:network]
    network = LocalNetwork.where("lower(name) = ?", name.downcase).first!
    @page = LocalNetworkPage.new(network)
  end

  def region
    region = params[:region]
    set_current_container_by_path "/engage-locally/#{region}"
    @page = EngageLocallyPage.new(current_container, current_payload_data)
    # TODO @ghedamat refactor the country specific menu
    @region = region
    @networks = networks_for_region
    render 'redesign/static/engage_locally'
  end

  def redirect_to_network
    if params[:country_code]
      country = Country.includes(:local_network).find_by(code: params[:country_code])

      continent = continent_region.invert[country.region]

      redirect_to "/engage-locally/#{continent}/#{URI.escape(country.local_network.name)}".downcase, status: :moved_permanently
    else
      redirect_to root_path
    end
  end

  private

  def networks_for_region
    slugs = continent_region
    LocalNetwork.
      joins(:countries).
      where('countries.region = ?', slugs[@region]).
      distinct('local_networks.id')
  end

  def continent_region
    {
      'africa'         =>  'africa',
      'asia'           =>  'asia',
      'europe'         =>  'europe',
      'latin-america'  =>  'latin_america',
      'mena'           =>  'mena',
      'north-america'  =>  'northern_america',
      'oceania'        =>  'oceania'
    }
  end
end
