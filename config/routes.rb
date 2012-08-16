UNGC::Application.routes.draw do
  root => 'pages#view', :path => ["index.html"]
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :login
  resource :session
  resource :password
  match 'no_session' => 'signup#no_session', :as => :no_session
  match '/admin/dashboard' => 'admin#dashboard', :as => :dashboard
  match '/admin/parameters' => 'admin#parameters', :as => :parameters
  match '/admin/cops/introduction' => 'admin/cops#introduction', :as => :cop_introduction
  match 'admin/local_networks/:id/knowledge_sharing' => 'admin/local_networks#knowledge_sharing', :as => :knowledge_sharing, :via => :get
  match '{:controller=>"admin/pages"}' => '#index', :as => :with_options
  match '/admin' => 'admin#dashboard', :as => :admin

  namespace :admin do
    resources :events do
      member do
        post :approve
        post :revoke
      end
    end

    resources :headlines do
      member do
        post :approve
        post :revoke
      end
    end

    resources :pages do
      collection do
        get :pending
        post :save_tree
        post :create_folder
      end

      member do
        put :approve
        put :check
        post :rename
      end
    end

    resources :contacts do
      collection do
        get :search
      end
    end

    resources :organizations do
      collection do
        get :approved
        get :rejected
        get :pending_review
        get :in_review
        get :updated
        get :network_review
        get :search
      end

      member do
        get :reverse_roles
      end

      resources :logo_requests do
        collection do
          get :approved
          get :rejected
          get :pending_review
          get :in_review
          get :unreplied
          get :accepted
        end
      end

      resources :logo_requests do
        member do
          post :agree
          get :download
        end
      end

      resources :case_stories
      resources :communication_on_progresses
    end

    resources :case_stories
    resources :logo_requests
    resources :communication_on_progresses
    resources :initiatives
    resources :contacts_roles
    resources :roles
    resources :sectors
    resources :countries
    resources :logo_files
    resources :cop_questions

    resources :local_networks do
      resources :local_network_events do
        resources :attachments
      end
    end

    match '/uploaded_files/:id/:filename' => 'uploaded_files#show', :as => :uploaded_file, :filename => /.*/
    match 'reports' => 'reports#index', :as => :reports
    match 'reports/:action.:format' => 'reports#index', :as => :report
    match '{:controller=>"learning"}' => '#index', :as => :with_options
  end

  match '/feeds/cops' => 'cops#feed', :format => 'atom'
  match 'climate' => 'pages#redirect_to_page', :page => '/Issues/Environment/Climate_Change/'
  match 'watermandate' => 'pages#redirect_to_page', :page => '/Issues/Environment/CEO_Water_Mandate/'
  match 'weps' => 'pages#redirect_to_page', :page => '/Issues/human_rights/equality_means_business.html'
  match 'networks' => 'pages#redirect_to_page', :page => '/NetworksAroundTheWorld/index.html'
  match 'ungcweek' => 'pages#redirect_to_page', :page => '/NewsAndEvents/global_compact_week.html'
  match 'rio_resources' => 'pages#redirect_to_page', :page => '/docs/news_events/upcoming/RioCSF/html/resources.html'
  match 'leadlab' => 'pages#redirect_to_page', :page => 'http://leadlab.unglobalcompact.org/'
  match ':lead' => 'pages#redirect_to_page', :page => '/HowToParticipate/Lead/', :constraints => { :lead => /lead/i }
  match '/NetworksAroundTheWorld/display.html' => 'pages#redirect_local_network', :as => :redirect_local_network
  match '{:controller=>"participants"}' => '#index', :as => :with_options
  match 'COPs/:navigation/:id' => 'cops#show', :as => :cop_detail_with_nav, :constraints => { :id => /\d+/ }
  match 'COPs/detail/:id' => 'cops#show', :as => :cop_detail, :constraints => { :id => /\d+/ }
  match 'organizations/new/:org_type' => 'organizations#new'
  match '{:controller=>"signup"}' => '#index', :as => :with_options
  match '{:controller=>"case_stories"}' => '#index', :as => :with_options
  match '{:controller=>"events"}' => '#index', :as => :with_options
  match '{:controller=>"news"}' => '#index', :as => :with_options
  match '/search' => 'search#index', :as => :search
  match 'decorate/*path' => 'pages#decorate', :as => :decorate_page
  match 'preview/*path' => 'pages#preview', :as => :preview_page
  match '*path' => 'pages#view', :as => :view_page
end
