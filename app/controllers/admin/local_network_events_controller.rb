class Admin::LocalNetworkEventsController < Admin::LocalNetworkSubmodelController
  before_filter :no_access_to_other_local_networks, :except => [:show] 
  
  def show
  end

  private

  def submodel
    LocalNetworkEvent
  end

  def submodel_association_method
    'events'
  end

  def return_url
    knowledge_sharing_path(@local_network, :tab => @tab)
  end
end


