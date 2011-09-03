class Admin::LocalNetworkSubmodelController < AdminController
  before_filter :load_local_network, :set_return_tab
  before_filter :build_submodel, :only => [:new, :create]
  before_filter :load_submodel,  :only => [:show, :edit, :update, :destroy]

  helper Admin::LocalNetworkSubmodelHelper
  helper_method :submodel

  def show
    file = @submodel.file
    send_file file.full_filename, :type => file.content_type, :disposition => 'inline'
  end

  def create
    @submodel.attributes = params[submodel.name.underscore]
    
    if @submodel.save
      flash[:notice] = "#{submodel.name} was successfully created."
      redirect_to admin_local_network_path(@local_network, :tab => @tab)
    else
      render :action => "new"
    end
  end

  def update
    @submodel.attributes = params[submodel.name.underscore]

    if @submodel.save
      flash[:notice] = "#{submodel.name} was successfully updated."
      redirect_to admin_local_network_path(@local_network, :tab => @tab)
    else
      render :action => "edit"
    end
  end

  def destroy
    if @submodel.destroy
      flash[:notice] = "#{submodel.name} was successfully deleted."
    else
      flash[:error] = @submodel.errors.full_messages.to_sentence
    end

    redirect_to admin_local_network_path(@local_network, :tab => @tab)
  end

  private

  def load_local_network
    @local_network = LocalNetwork.find(params[:local_network_id])
  end

  def load_submodel
    @submodel = submodels_proxy.find(params[:id])
  end

  def build_submodel
    @submodel = submodels_proxy.build
  end

  def submodels_proxy
    @local_network.send(submodel.name.underscore.pluralize)
  end
  
  # select same tab after cancelling or completing an operation
  def set_return_tab
    @tab = submodel.name.underscore.pluralize 
  end


end

