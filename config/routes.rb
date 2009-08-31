ActionController::Routing::Routes.draw do |map|
  map.view_page '/pages/*path', :controller => 'pages', :action => 'view'
  map.resources :organizations

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
