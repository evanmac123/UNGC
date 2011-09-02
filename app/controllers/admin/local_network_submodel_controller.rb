class Admin::LocalNetworkSubmodelController < AdminController
  before_filter :load_local_network
  before_filter :build_submodel, :only => [:new, :create]
  before_filter :load_submodel, :only => [:show, :edit, :update, :destroy]

  def create
    @submodel.attributes = params[submodel.name.underscore]

    if @submodel.save
      flash[:notice] = "#{submodel.name} was successfully created."
      redirect_user_to_appropriate_screen
    else
      render :action => "new"
    end
  end

  def update
    @submodel.attributes = params[submodel.name.underscore]

    if @submodel.save
      flash[:notice] = "#{submodel.name} was successfully updated."
      redirect_user_to_appropriate_screen
    else
      render :action => "edit"
    end
  end

  def destroy
    if @submodel.destroy
      flash[:notice] = "#{submodel.name} was successfully deleted."
    else
      flash[:error] =  @submodel.errors.full_messages.to_sentence
    end

    redirect_user_to_appropriate_screen
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

  def redirect_user_to_appropriate_screen
    if current_user.from_ungc?
      redirect_to admin_local_network_path(@local_network, :tab => submodel.name.underscore)
    else
      redirect_to dashboard_path(:tab => submodel.name.underscore)
    end
  end
end

