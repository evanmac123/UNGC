ActionController::Routing::Routes.draw do |map|
  map.view_page '/pages/*path', :controller => 'pages', :action => 'view'
end
