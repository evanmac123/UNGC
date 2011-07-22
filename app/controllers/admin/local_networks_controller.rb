class Admin::LocalNetworksController < AdminController
  before_filter :load_local_network, :only => [:edit, :destroy]
  before_filter :no_organization_or_local_network_access
  before_filter :no_access_to_other_local_networks

  def index
    @local_networks = LocalNetwork.all(:order => order_from_params)
  end

  def new
    @local_network = LocalNetwork.new
  end
  
  def show
    @local_network = LocalNetwork.find(params[:id])
  end
  
  def edit
    @local_network = LocalNetwork.find(params[:id])
  end

  def create
    @local_network = LocalNetwork.new(params[:local_network])
    if @local_network.save
      flash[:notice] = 'Local Network was successfully created.'
      redirect_to(admin_local_networks_path)
    else
      render :action => "new"
    end
  end

  def update
    @local_network = LocalNetwork.find(params[:id])
    if @local_network.update_attributes(params[:local_network])
      flash[:notice] = 'Local Network was successfully updated.'
      
      if current_user.from_ungc?
        redirect_to admin_local_network_path(@local_network.id)
      elsif current_user.from_network?
        redirect_to dashboard_path
      end
      
    else
      render :action => "edit"
    end
  end

  def destroy
    @local_network = LocalNetwork.find(params[:id])
    @local_network.destroy
    redirect_to(admin_local_networks_path)
  end
  
  private

    def order_from_params
      @order = [params[:sort_field] || 'name', params[:sort_direction] || 'ASC'].join(' ')
    end
    
    def load_local_network
      @local_network = LocalNetwork.find(params[:id])
    end
    
end
