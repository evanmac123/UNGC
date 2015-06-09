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

  private

  def networks_for_region
    slugs = {
      'africa'         =>  'africa',
      'asia'           =>  'asia',
      'europe'         =>  'europe',
      'latin-america'  =>  'latin_america',
      'mena'           =>  'mena',
      'north-america'  =>  'northern_america',
      'oceania'        =>  'oceania'
    }
    LocalNetwork.joins(:countries).where('countries.region = ?', slugs[@region])
  end
end
