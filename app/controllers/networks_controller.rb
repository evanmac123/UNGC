class NetworksController < Redesign::ApplicationController
  def show
    name = params[:network]
    network = LocalNetwork.where("lower(name) = ?", name.downcase).first!
    @page = LocalNetworkPage.new(network)
  end

  def region
    region = params[:region]
    set_current_container_by_path "/engage-locally/#{region}"
    @page = EngageLocallyRegionPage.new(current_container, current_payload_data, region)
  end

  def redirect_to_network
    if params[:country_code]
      country = Country.includes(:local_network).find_by!(code: params[:country_code])

      continent = Region.find_by(name: country.region).param
      if country.local_network
        redirect_to "/engage-locally/#{continent}/#{URI.escape(country.local_network.name)}".downcase, status: :moved_permanently
      else
        raise ActiveRecord::RecordNotFound
      end

    else
      redirect_to root_path
    end
  end

end
