class Admin::LocalNetworkEventsController < Admin::LocalNetworkSubmodelController
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


