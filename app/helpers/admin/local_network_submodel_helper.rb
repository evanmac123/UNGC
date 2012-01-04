module Admin::LocalNetworkSubmodelHelper
  def submodels_path
    send "admin_local_network_#{submodel.name.underscore.pluralize}_path", @local_network
  end

  def submodel_path(sm)
    send "admin_local_network_#{sm.class.name.underscore}_path", @local_network, sm
  end

  def edit_submodel_path(sm)
    send "edit_admin_local_network_#{sm.class.name.underscore}_path", @local_network, sm
  end

end

