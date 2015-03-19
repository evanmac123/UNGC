require 'ckeditor'

UNGC::Application.routes.draw do
  # Root
  root :to => 'pages#home'

  devise_for :contacts,
    path: '/',
    path_names: {
      sign_in: 'login',
      sign_out: 'logout'
    },
    controllers: {
      sessions: 'sessions',
      passwords: 'admin/passwords'
    }

  namespace :redesign do
    namespace :admin do
      namespace :api, format: :json do
        resources :layouts, only: [:index, :show]
        resources :containers
        resources :payloads
      end

      get '/(*path)' => 'index#frontend', as: :root, format: :html
    end

    controller :library do
      get '/our-library'        => :index,     as: :library
      get '/our-library/search' => :search,    as: :library_search
    end

    get '/participation' => 'static#landing', as: :landing_page
    get '/article' => 'static#article', as: :article
    get '/long_article' => 'static#long_article', as: :long_article
    get '/' => 'static#home', as: :root
  end

  # Backend routes
  get '/admin'                    => 'admin#dashboard', :as => :admin
  get '/admin/dashboard'          => 'admin#dashboard', :as => :dashboard
  get '/admin/parameters'         => 'admin#parameters', :as => :parameters
  get '/admin/cops/introduction'  => 'admin/cops#introduction', :as => :cop_introduction

  get '/admin/local_networks/:id/knowledge_sharing' => 'admin/local_networks#knowledge_sharing', :as => :knowledge_sharing
  get '/admin/local_network_resources' => 'admin/local_networks#edit_resources', :as => :local_network_resources

  # These need to come before resources :pages
  get '/admin/pages/:id/edit'   => 'admin/pages#edit', :as => :edit_page
  put '/admin/page/:id.:format' => 'admin/pages#update', :as => :update_page
  post '/admin/page/:id/edit'    => 'admin/pages#edit'
  get '/admin/pages/find'       => 'admin/pages#find_by_path_and_redirect_to_latest', :as => :find_page_by

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
      resources :communication_on_progresses, :controller => 'cops' do
        resources :files, :controller => 'cop_files', only: [:index, :new, :create, :destroy]
        member do
          get  :backdate
          post :do_backdate
        end
      end

      resources :grace_letters, except: :index
      resources :reporting_cycle_adjustments, except: :index

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
    resources :roles, except: [:show]
    resources :sectors, except: [:show]
    resources :countries
    resources :logo_files
    resources :cop_questions

    resources :local_networks do
      resources :contacts
      resources :awards, except: [:index, :show]
      resources :mous, except: [:index, :show]
      resources :meetings, except: [:index, :show]
      resources :communications, except: [:index, :show]
      resources :integrity_measures
      resources :annual_reports, except: [:index, :show]
      resources :announcements, except: [:index, :show]
      resources :local_network_events, except: [:index] do
        resources :attachments, :controller => 'local_network_event_attachments', except: [:show, :edit, :update]
      end
      resources :annual_reports
      resources :contribution_descriptions
    end

    get '/uploaded_files/:id/:filename' => 'uploaded_files#show', :as => :uploaded_file, :constraints => { :filename => /.*/ }

    get 'reports'              => 'reports#index',     :as => :reports
    get 'reports/status/:id'   => 'reports#status',    :as => :report_status
    get 'reports/download/:id' => 'reports#download',  :as => :report_download
    get 'reports/:action'      => 'reports',           :as => :report

    get 'learning'         => 'learning#index', :as => :learning
    get 'learning/:action' => 'learning'

    resources :resources do
      member do
        post :approve
        post :revoke
      end
    end
  end

  resources :organizations, :only => :index

  # Salesforce webook routes
  namespace :salesforce, defaults: { format: 'json' } do
    post '/sync' => 'api#sync'
  end

  # Front-end routes
  get '/feeds/cops' => 'cops#feed', :format => 'atom'

  # Alias redirects
  get '/climate'        => 'pages#redirect_to_page', :page => '/Issues/Environment/Climate_Change/'
  get '/watermandate'   => 'pages#redirect_to_page', :page => '/Issues/Environment/CEO_Water_Mandate/'
  get '/weps'           => 'pages#redirect_to_page', :page => '/Issues/human_rights/equality_means_business.html'
  get '/networks'       => 'pages#redirect_to_page', :page => '/NetworksAroundTheWorld/index.html'
  get '/rio_resources'  => 'pages#redirect_to_page', :page => '/docs/news_events/upcoming/RioCSF/html/resources.html'
  get '/leadlab'        => 'pages#redirect_to_page', :page => 'http://leadlab.unglobalcompact.org/'
  get '/LEADBoardProgramme' => 'pages#redirect_to_page', :page => '/docs/issues_doc/lead/board_programme/'
  get ':lead'           => 'pages#redirect_to_page', :page => '/HowToParticipate/Lead/', :constraints => { :lead => /lead/i }
  get '/app'            => 'pages#redirect_to_page', :page => 'http://ungcevents.quickmobile.mobi/'
  get '/businesspartnershiphub' => 'pages#redirect_to_page', :page => 'http://businesspartnershiphub.org/'
  get '/HR_Resources'   => 'pages#redirect_to_page', :page => '/docs/issues_doc/human_rights/Resources/HR_Postcard.pdf'
  get ':fabprinciples'           => 'pages#redirect_to_page', :page => '/Issues/Environment/food_agriculture_business_principles.html', :constraints => { :fabprinciples => /fabprinciples/i }
  get '/ActionFair'     => 'pages#redirect_to_page', :page => '/docs/news_events/upcoming/ActionFairSources.pdf'
  get '/lnw'            => 'pages#redirect_to_page', :page => '/docs/networks_around_world_doc/google_earth/'
  get '/FundraisingToolkit' => 'pages#redirect_to_page', :page => '/docs/networks_around_world_doc/LN_Fundraising_Toolkit.pdf'
  get '/anti-corruption' => 'pages#redirect_to_page', :page => '/Issues/transparency_anticorruption/call_to_action_post2015.html'
  get '/UNPrivateSectorForum' => 'pages#redirect_to_page', :page => '/Issues/Business_Partnerships/un_private_sector_forum_2014.html'
  get '/LEADSymposium' => 'pages#redirect_to_page', :page => '/HowToParticipate/Lead/lead_symposium.html'
  get ':leadsymposiumonline' => 'pages#redirect_to_page', :page => 'http://un.banks-sadler.com', :constraints => { :leadsymposiumonline => /leadsymposiumonline/i }
  get ':boardprogramme' => 'pages#redirect_to_page', :page => '/HowToParticipate/Lead/board_programme.html', :constraints => { :boardprogramme => /boardprogramme/i }

  get '/NetworksAroundTheWorld/display.html' => 'pages#redirect_local_network', :as => :redirect_local_network

  get '/participants/search' => 'participants#search', :as => :participant_search
  get '/participants/:navigation/:id' => 'participants#show', :as => :participant_with_nav, :constraints => { :id => /.*/ }
  get '/participant/:id' => 'participants#show', :as => :participant, :constraints => { :id => /.*/ }

  # Resources
  get '/resources/:id' => 'resources#show', :as => :resource
  post '/resources/link_views' => 'resources#link_views', :as => :resources_link_view
  get '/resources' => 'resources#index', :as => :resources

  get 'COPs/:navigation/:id' => 'cops#show', :as => :cop_detail_with_nav, :constraints => { :id => /\d+/ }
  get 'COPs/detail/:id' => 'cops#show', :as => :cop_detail, :constraints => { :id => /\d+/ }
  get 'organizations/new/:org_type' => 'organizations#new'

  # Signup
  get   '/HowToParticipate/Business_Organization_Information.html' => 'signup#step1', :defaults => { :org_type =>"business" }
  get   '/HowToParticipate/Organization_Information.html' => 'signup#step1', :defaults => { :org_type =>"non_business" }
  get   '/signup/step1/:org_type'  => 'signup#step1', :as => :organization_step1
  match '/signup/step2'            => 'signup#step2', :as => :organization_step2, via: [:get, :post]
  match '/signup/step3'            => 'signup#step3', :as => :organization_step3, via: [:get, :post]
  match '/signup/step4'            => 'signup#step4', :as => :organization_step4, via: [:get, :post]
  match '/signup/step5'            => 'signup#step5', :as => :organization_step5, via: [:get, :post]
  match '/signup/step6'            => 'signup#step6', :as => :organization_step6, via: [:get, :post]
  post  '/signup/step7'            => 'signup#step7', :as => :organization_step7

  get '/case_story/:id' => 'case_stories#show', :as => 'case_story'

  get '/events/:permalink' => 'events#show', :as => :event

  # News
  get '/news' => 'news#index', :as => :newest_headlines
  get '/feeds/news' => 'news#index', :format => 'atom'
  get '/news/:year' => 'news#index', :as => :headline_year, :constraints => { :year => /\d{4}/ }
  get '/news/:permalink' => 'news#show', :as => :headline

  get '/search' => 'search#index', :as => :search

  get '/decorate/*path' => 'pages#decorate', :as => :decorate_page, :format => false
  get '/preview/*path'  => 'pages#preview',  :as => :preview_page,  :format => false
  get '/*path'          => 'pages#view',     :as => :view_page,     :format => false

  mount Ckeditor::Engine => "/ckeditor"
end
