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
  
  def display_errors_for_submodel(sm)
     error_messages = sm.readable_error_messages.map { |error| content_tag :li, error }
     content_tag :ul, error_messages.join
  end
  
  
end

