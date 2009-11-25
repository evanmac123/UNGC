ActionController::Routing::Routes.draw do |map|
  # Root
    map.root :controller => 'pages', :action => 'view', :path => ['index.html']
  
  # Session routes
    map.resource :session
    map.no_session 'no_session', :controller => 'signup', :action => 'no_session'
    map.logout '/logout', :controller => 'sessions', :action => 'destroy'
    map.login '/login', :controller => 'sessions', :action => 'new'
  
  # Back-end routes
    map.dashboard '/admin/dashboard', :controller => 'admin', :action => 'dashboard'

    # These need to come before resources :pages
    map.with_options :controller => 'admin/pages' do |m|
      m.edit_page 'admin/pages/:id/edit', :action => 'edit', :conditions => { :method => :get }
      m.update_page 'admin/page/:id.:format', :action => 'update', :conditions => { :method => :put }
      m.connect 'admin/page/:id/edit', :action => 'update', :conditions => { :method => :post }
      m.find_page_by 'admin/pages/find', :action => 'find_by_path_and_redirect_to_latest'
    end

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
          :revoke  => :post,
          :meta    => :get
        },
        :collection => {
          :pending => :get
        }
    
      admin.resources :organizations, :collection => { :approved => :get, :rejected => :get, :pending_review => :get },
                                      :has_many   => [:contacts, :comments] do |organization|
        organization.resources :logo_requests, :member => {:agree => :post, :download => :get}
        organization.resources :case_stories
        organization.resources :communication_on_progresses, :controller => 'cops'
      end

      admin.resources :case_stories, :has_many => :comments
      admin.resources :logo_requests, :has_many => :logo_comments
      admin.resources :communication_on_progresses, :has_many => :comments
      admin.resources :initiatives, :has_many => :signings
      admin.resources :contacts_roles
    
      admin.reports 'reports', :controller => 'reports', :action => 'index'
      admin.report 'reports/:action.:format', :controller => 'reports'
    end

  # Front-end routes
    map.redirect_local_network '/NetworksAroundTheWorld/display.html',
      :controller => 'pages',
      :action => 'redirect_local_network'

    map.resources :bulletin_subscribers #, :has_many => :comments

    map.with_options :controller => 'participants' do |m|
      m.participant_search 'participants/search', :action => 'search'
      
      # Needs to catch dots in the org id
      m.with_options :action => 'show', :requirements => { :id => /.*/ } do |n|
        n.participant_with_nav 'participants/:navigation/:id'
        n.participant 'participant/:id'
      end
    end

    map.cop_detail_with_nav 'COPs/:navigation/:organization/:cop', 
      :controller => 'cops', 
      :action => 'show', 
      :requirements => { :organization => /.*/, :cop => /.*/ }
    map.cop_detail 'COPs/detail/:organization/:cop', 
      :controller => 'cops', 
      :action => 'show', 
      :requirements => { :organization => /.*/, :cop => /.*/ }

    # shorcut for new organization
    map.connect 'organizations/new/:org_type', :controller => 'organizations', :action => 'new'
    map.with_options :controller => 'signup' do |signup|
      signup.organization_step1 'signup/step1/:org_type', :action => 'step1'
      signup.organization_step2 'signup/step2',           :action => 'step2'
      signup.organization_step3 'signup/step3',           :action => 'step3'
      signup.organization_step4 'signup/step4',           :action => 'step4'
      signup.organization_step5 'signup/step5',           :action => 'step5'
    end

    map.with_options :controller => 'case_stories' do |m|
      m.case_story 'case_story/:id', :action => :show
    end
    map.with_options :controller => 'events' do |m|
      m.event '/events/:permalink', :action => :show, :conditions => { :method => :get }
    end
    map.with_options :controller => 'news' do |m|
      m.newest_headlines '/news', :action => :index
      m.newest_headlines '/news/feed.atom', :action => :index, :format => 'atom'
      m.headline_year '/news/:year', :action => :index, :requirements => { :year => /\d{4}/ }
      m.headline '/news/:permalink', :action => :show, :conditions => { :method => :get }
    end

    map.search '/search', :controller => 'search', :action => 'index'

    map.decorate_page 'decorate/*path', :controller => 'pages', :action => 'decorate'
    map.view_page '*path', :controller => 'pages', :action => 'view'
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
