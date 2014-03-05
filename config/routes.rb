require 'ckeditor'

UNGC::Application.routes.draw do
  # Root
  root :to => 'pages#home'

  devise_for :contacts
  devise_scope :contact do
    post    '/login'             => 'sessions#create',             :as => :contact_session
    get     '/login'             => 'sessions#new',                :as => :new_contact_session
    delete  '/logout'            => 'sessions#destroy',            :as => :destroy_contact_session
    get     '/password/new'      => 'admin/passwords#new',         :as => :new_contact_password
    post    '/password'          => 'admin/passwords#create',      :as => :contact_password
    put     '/password'          => 'admin/passwords#update'
    get     '/password/edit'     => 'admin/passwords#edit',        :as => :edit_contact_password
  end

  # Backend routes
  match '/admin'                    => 'admin#dashboard', :as => :admin
  match '/admin/dashboard'          => 'admin#dashboard', :as => :dashboard
  match '/admin/parameters'         => 'admin#parameters', :as => :parameters
  match '/admin/cops/introduction'  => 'admin/cops#introduction', :as => :cop_introduction

  match '/admin/local_networks/:id/knowledge_sharing' => 'admin/local_networks#knowledge_sharing', :as => :knowledge_sharing, :via => :get
  match '/admin/local_network_resources' => 'admin/local_networks#edit_resources', :as => :local_network_resources, :via => :get

  # These need to come before resources :pages
  match '/admin/pages/:id/edit'   => 'admin/pages#edit', :as => :edit_page, :via => :get
  match '/admin/page/:id.:format' => 'admin/pages#update', :as => :update_page, :via => :put
  match '/admin/page/:id/edit'    => 'admin/pages#edit', :via => :post
  match '/admin/pages/find'       => 'admin/pages#find_by_path_and_redirect_to_latest', :as => :find_page_by

  namespace :admin do
    resources :events do
      member do
        post :approve
        post :revoke
      end
    end

    resources :headlines, :controller => 'news' do
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
      resources :comments
      collection do
        get :approved
        get :rejected
        get :pending_review
        get :in_review
        get :updated
        get :network_review
        get :delay_review
        get :search
      end

      member do
        get :reverse_roles
        get :show_welcome_letter
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

        member do
          post :agree
          get :download
        end
      end

      resources :case_stories
      resources :communication_on_progresses, :controller => 'cops'

      resources :contacts
    end

    resources :case_stories do
      resources :comments
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

      member do
        post :agree
        get :download
      end

      resources :logo_comments
    end

    resources :communication_on_progresses, :controller => 'cops'
    resources :initiatives do
      resources :signings
    end
    resources :contacts_roles
    resources :roles
    resources :sectors
    resources :countries
    resources :logo_files
    resources :cop_questions

    resources :local_networks do
      resources :contacts
      resources :awards
      resources :mous
      resources :meetings
      resources :communications
      resources :integrity_measures
      resources :annual_reports
      resources :announcements
      resources :local_network_events do
        resources :attachments, :controller => 'local_network_event_attachments'
      end
      resources :annual_reports
    end

    match '/uploaded_files/:id/:filename' => 'uploaded_files#show', :as => :uploaded_file, :constraints => { :filename => /.*/ }

    match 'reports'          => 'reports#index', :as => :reports
    match 'reports/:action'  => 'reports', :as => :report

    match 'learning'         => 'learning#index', :as => :learning
    match 'learning/:action' => 'learning'

    resources :resources do
      member do
        post :approve
        post :revoke
      end
    end
  end

  resources :organizations, :only => :index

  # Front-end routes
  match '/feeds/cops' => 'cops#feed', :format => 'atom'

  # Alias redirects
  match '/climate'        => 'pages#redirect_to_page', :page => '/Issues/Environment/Climate_Change/'
  match '/watermandate'   => 'pages#redirect_to_page', :page => '/Issues/Environment/CEO_Water_Mandate/'
  match '/weps'           => 'pages#redirect_to_page', :page => '/Issues/human_rights/equality_means_business.html'
  match '/networks'       => 'pages#redirect_to_page', :page => '/NetworksAroundTheWorld/index.html'
  match '/rio_resources'  => 'pages#redirect_to_page', :page => '/docs/news_events/upcoming/RioCSF/html/resources.html'
  match '/leadlab'        => 'pages#redirect_to_page', :page => 'http://leadlab.unglobalcompact.org/'
  match '/LEADBoardProgramme' => 'pages#redirect_to_page', :page => '/docs/issues_doc/lead/board_programme/'
  match ':lead'           => 'pages#redirect_to_page', :page => '/HowToParticipate/Lead/', :constraints => { :lead => /lead/i }
  match '/app'            => 'pages#redirect_to_page', :page => 'http://ungcevents.quickmobile.mobi/'
  match '/businesspartnershiphub' => 'pages#redirect_to_page', :page => 'http://businesspartnershiphub.org/'
  match '/HR_Resources'   => 'pages#redirect_to_page', :page => '/docs/issues_doc/human_rights/Resources/HR_Postcard.pdf'
  match ':sabp'           => 'pages#redirect_to_page', :page => '/Issues/partnerships/sustainable_agriculture_business_principles.html', :constraints => { :sabp => /sabp/i }
  match '/ActionFair'     => 'pages#redirect_to_page', :page => '/docs/news_events/upcoming/ActionFairSources.pdf'
  match '/lnw'            => 'pages#redirect_to_page', :page => '/docs/networks_around_world_doc/google_earth/'
  match '/docs/news_events/2012_CSF/Rio_CSF_Overview_Outcomes.pdf' => 'pages#redirect_to_page', :page => 'http://weprinciples.org'

  match '/NetworksAroundTheWorld/display.html' => 'pages#redirect_local_network', :as => :redirect_local_network

  match '/participants/search' => 'participants#search', :as => :participant_search
  match '/participants/:navigation/:id' => 'participants#show', :as => :participant_with_nav, :constraints => { :id => /.*/ }
  match '/participant/:id' => 'participants#show', :as => :participant, :constraints => { :id => /.*/ }

  # Resources
  get '/resources/:id' => 'resources#show', :as => :resource
  post '/resources/link_views' => 'resources#link_views', :as => :resources_link_view
  match '/resources' => 'resources#index', :as => :resources

  match 'COPs/:navigation/:id' => 'cops#show', :as => :cop_detail_with_nav, :constraints => { :id => /\d+/ }
  match 'COPs/detail/:id' => 'cops#show', :as => :cop_detail, :constraints => { :id => /\d+/ }
  match 'organizations/new/:org_type' => 'organizations#new'

  # Signup
  match '/HowToParticipate/Business_Organization_Information.html' => 'signup#step1', :defaults => { :org_type =>"business" }
  match '/HowToParticipate/Organization_Information.html' => 'signup#step1', :defaults => { :org_type =>"non_business" }
  match '/signup/step1/:org_type'  => 'signup#step1', :as => :organization_step1
  match '/signup/step2'            => 'signup#step2', :as => :organization_step2
  match '/signup/step3'            => 'signup#step3', :as => :organization_step3
  match '/signup/step4'            => 'signup#step4', :as => :organization_step4
  match '/signup/step5'            => 'signup#step5', :as => :organization_step5
  match '/signup/step6'            => 'signup#step6', :as => :organization_step6
  match '/signup/step7'            => 'signup#step7', :as => :organization_step7

  match '/case_story/:id' => 'case_stories#show', :as => 'case_story'

  match '/events/:permalink' => 'events#show', :via => :get, :as => :event

  # News
  match '/news' => 'news#index', :as => :newest_headlines
  match '/feeds/news' => 'news#index', :as => :newest_headlines, :format => 'atom'
  match '/news/:year' => 'news#index', :as => :headline_year, :constraints => { :year => /\d{4}/ }
  match '/news/:permalink' => 'news#show', :as => :headline, :via => :get

  match '/search' => 'search#index', :as => :search

  match '/decorate/*path' => 'pages#decorate', :as => :decorate_page, :format => false
  match '/preview/*path'  => 'pages#preview',  :as => :preview_page,  :format => false
  match '/*path'          => 'pages#view',     :as => :view_page,     :format => false

  mount Ckeditor::Engine => "/ckeditor"
end
