ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'view', :path => ['index.html']

  map.redirect_local_network '/NetworksAroundTheWorld/display.html',
    :controller => 'pages',
    :action => 'redirect_local_network'

  map.resources :organizations, :member     => { :approve => :post, :reject => :post },
                                :collection => { :approved => :get, :rejected => :get, :pending_review => :get },
                                :has_many   => [:contacts, :comments] do |organization|
    organization.resources :logo_requests, :member => {:agree => :post, :download => :get}
    organization.resources :case_stories
    organization.resources :communication_on_progresses, :controller => 'admin/cops'
  end
  map.resources :logo_requests, :has_many => :logo_comments
  map.resources :case_stories, :has_many => :comments
  map.resources :communication_on_progresses, :has_many => :comments
  map.resources :bulletin_subscribers, :has_many => :comments

  map.participant_with_nav 'participants/:navigation/:id', 
    :controller => 'participants', 
    :action => 'show', 
    :requirements => { :id => /.*/ }
  map.participant 'participant/:id', 
    :controller => 'participants', 
    :action => 'show', 
    :requirements => { :id => /.*/ }

  map.cop_detail_with_nav 'COPs/:navigation/:organization/:cop', 
    :controller => 'cops', 
    :action => 'show', 
    :requirements => { :organization => /.*/, :cop => /.*/ }
  map.cop_detail 'COPs/detail/:organization/:cop', 
    :controller => 'cops', 
    :action => 'show', 
    :requirements => { :organization => /.*/, :cop => /.*/ }

  map.resource :session
  
  # shorcut for new organization
  map.connect 'organizations/new/:org_type', :controller => 'organizations', :action => 'new'
  map.organization_step1 'signup/step1/:org_type', :controller => 'signup', :action => 'step1'
  (2..5).each {|i| eval("map.organization_step#{i} 'signup/step#{i}', :controller => 'signup', :action => 'step#{i}'")}
  
  map.no_session 'no_session', :controller => 'signup', :action => 'no_session'

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.dashboard '/admin/dashboard', :controller => 'admin', :action => 'dashboard'

  # map.resources :events
  map.with_options :controller => 'events' do |m|
    m.event '/events/:permalink', :action => :show, :conditions => { :method => :get }
  end
  map.with_options :controller => 'news' do |m|
    m.newest_headlines '/news', :action => :index
    m.newest_headlines '/news/feed.atom', :action => :index, :format => 'atom'
    m.headline_year '/news/:year', :action => :index, :requirements => { :year => /\d{4}/ }
    m.headline '/news/:permalink', :action => :show, :conditions => { :method => :get }
  end

  map.find_page_by 'admin/pages/find', :controller => 'admin/pages', :action => 'find_by_path_and_redirect_to_latest'

  map.namespace :admin do |admin|
    admin.resources :events, :member => { 
      :approve => :post, 
      :revoke => :post 
    }
    admin.resources :headlines, 
      :controller => 'news', 
      :member => { 
        :approve => :post, 
        :revoke => :post 
      }
    admin.resources :pages,
      :member => {
        :approve => :post,
        :revoke  => :post
      }
  end
  
  # reports
  map.reports 'admin/reports', :controller => 'reports', :action => 'index'
  map.report 'admin/reports/:action.:format', :controller => 'reports'
  
  map.with_options :controller => 'admin/pages' do |m|
    m.edit_page 'admin/pages/:id/edit', :action => 'edit', :conditions => { :method => :get }
    m.update_page 'admin/page/:id.:format', :action => 'update', :conditions => { :method => :put }
    m.connect 'admin/page/:id/edit', :action => 'update', :conditions => { :method => :post }
  end

  map.decorate_page 'decorate/*path', :controller => 'pages', :action => 'decorate'
  map.view_page '*path', :controller => 'pages', :action => 'view'
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
