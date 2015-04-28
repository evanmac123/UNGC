class Redesign::NetworksController < Redesign::ApplicationController
  def show
    name = params[:network]
    @network = LocalNetwork.where("lower(name) = ?", name.downcase).first!
  end
end
