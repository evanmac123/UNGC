class Admin::LocalNetworksController < AdminController
  before_filter :load_local_network, :only => [:show, :edit, :destroy, :knowledge_sharing]
  before_filter :no_organization_or_local_network_access
  before_filter :no_access_to_other_local_networks, :except => [:update] 

  def index
    @local_networks = LocalNetwork.all(:order => order_from_params)
  end

  def new
    @local_network = LocalNetwork.new(:state => LocalNetwork::STATES[:emerging])
  end
  
  def show
    @local_network = LocalNetwork.find(params[:id])
    render 'show_ungc' if current_user.from_ungc?
  end
  
  def edit
    @local_network = LocalNetwork.find(params[:id])
    @section ||= params[:section]
    @form_partial = @section ? 'edit_' + @section : 'default_form'
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
    @section ||= params[:section]
    if @local_network.update_attributes(params[:local_network])
      flash[:notice] = 'Local Network was successfully updated.'
      
      if current_user.from_ungc?
        redirect_to admin_local_network_path(@local_network.id, :tab => 'network_management') 
      elsif current_user.from_network?
        redirect_to admin_local_network_path(@local_network.id, :tab => @section) 
      end
      
    else
      render :action => "edit"
    end
  end

  def knowledge_sharing
  
  end

  def destroy
    @local_network = LocalNetwork.find(params[:id])
    @local_network.destroy
    flash[:notice] = 'Local Network was deleted.'
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
