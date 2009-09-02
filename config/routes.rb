ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'view', :path => ['index.html']
  map.resources :organizations, :member     => { :approve => :post, :reject => :post },
                                :collection => { :approved => :get, :rejected => :get, :pending => :get },
                                :has_many   => [:contacts, :logo_requests]
  map.resources :logo_requests, :has_many => :logo_comments
                                :has_many   => :contacts
  
  map.with_options :controller => 'admin/content' do |m|
    m.edit_content 'admin/content/:id/edit', :action => 'edit', :conditions => { :method => :get }
  end

  map.decorate_page '/decorate/*path', :controller => 'pages', :action => 'decorate'
  map.view_page '/*path', :controller => 'pages', :action => 'view'
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
