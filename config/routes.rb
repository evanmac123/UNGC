ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'view', :path => ['index.html']
  map.resources :organizations, :member => { :approve => :post, :reject => :post }

  map.view_page '/*path', :controller => 'pages', :action => 'view'
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
