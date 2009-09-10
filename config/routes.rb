ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'view', :path => ['index.html']

  map.resources :organizations, :member     => { :approve => :post, :reject => :post },
                                :collection => { :approved => :get, :rejected => :get, :pending => :get },
                                :has_many   => [:contacts, :logo_requests]
  map.resources :logo_requests, :has_many => :logo_comments
  map.resource :session

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  
  map.with_options :controller => 'admin/content' do |m|
    m.edit_content 'admin/content/:id/edit', :action => 'edit', :conditions => { :method => :get }
    m.update_content 'admin/content/:id.:format', :action => 'update', :conditions => { :method => :put }
    m.connect 'admin/content/:id/edit', :action => 'update', :conditions => { :method => :post }
  end

  map.decorate_page 'decorate/*path', :controller => 'pages', :action => 'decorate'
  map.view_page '*path', :controller => 'pages', :action => 'view'
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
