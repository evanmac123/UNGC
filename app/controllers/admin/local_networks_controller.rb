class Admin::LocalNetworksController < AdminController
  before_filter :no_organization_or_local_network_access

  def index
    @local_networks = LocalNetwork.all(:order => 'name')
  end

  def new
    @local_network = LocalNetwork.new
  end

  def edit
    @local_network = LocalNetwork.find(params[:id])
  end

  def create
    @local_network = LocalNetwork.new(params[:local_network])
    if @local_network.save
      flash[:notice] = 'Local network was successfully created.'
      redirect_to(admin_local_networks_path)
    else
      render :action => "new"
    end
  end

  def update
    @local_network = LocalNetwork.find(params[:id])
    if @local_network.update_attributes(params[:local_network])
      flash[:notice] = 'LocalNetwork was successfully updated.'
      redirect_to(admin_local_networks_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @local_network = LocalNetwork.find(params[:id])
    @local_network.destroy
    redirect_to(admin_local_networks_path)
  end
end