class Admin::LocalNetworkSubmodelController < AdminController
  before_filter :load_local_network, :set_return_tab
  before_filter :build_submodel, :only => [:new, :create]
  before_filter :load_submodel,  :only => [:show, :edit, :update, :destroy]
  before_filter :no_access_to_other_local_networks, :except => [:index, :show]

  helper Admin::LocalNetworkSubmodelHelper
  helper_method :submodel, :return_url

  def create
    @submodel.attributes = submodel_params

    if @submodel.save
      flash[:notice] = "#{submodel.name.titleize} was successfully created."
      redirect_to return_url
    else
      render :action => "new"
    end
  end

  def update
    @submodel.attributes = submodel_params

    if @submodel.save
      flash[:notice] = "#{submodel.name.titleize} was successfully updated."
      redirect_to return_url
    else
      render :action => "edit"
    end
  end

  def destroy
    if @submodel.destroy
      flash[:notice] = "#{submodel.name.titleize} was successfully deleted."
    else
      flash[:error] = @submodel.errors.full_messages.to_sentence
    end
    redirect_to return_url
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
    @local_network.send(submodel_association_method)
  end

  def submodel_association_method
    submodel.name.underscore.pluralize
  end

  def return_url
    if submodel.local_network_model_type == :knowledge_sharing
      knowledge_sharing_path(@local_network, :tab => @tab)
    else
      admin_local_network_path(@local_network, :tab => @tab)
    end
  end

  # select same tab after cancelling or completing an operation
  def set_return_tab
    @tab = submodel.name.underscore.pluralize
  end

  def network_management_tab?
    submodel.local_network_model_type == :network_management
  end

  def knowledge_sharing_tab?
    submodel.local_network_model_type == :knowledge_sharing
  end

  def submodel_params
    params.require(submodel.name.underscore).permit!
  end

end

