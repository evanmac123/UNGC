require 'ckeditor'
require 'sidekiq/web'

class RedesignConstraint
  def initialize
  end

  def matches?(request)
    contact_id = request.session["warden.user.contact.key"].try(:[], 0).try(:[], 0)
    RedesignPreview.permitted?(contact_id)
  end
end

UNGC::Application.routes.draw do
  authenticate :contact, lambda { |c| c.from_ungc? } do
    mount Sidekiq::Web => '/back-the-web'
  end

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

  # Backend routes
  get '/admin'                    => 'admin#dashboard',         as: :admin
  get '/admin/dashboard'          => 'admin#dashboard',         as: :dashboard
  get '/admin/parameters'         => 'admin#parameters',        as: :parameters
  get '/admin/cops/introduction'  => 'admin/cops#introduction', as: :cop_introduction

  get '/admin/local_networks/:id/knowledge_sharing' => 'admin/local_networks#knowledge_sharing', :as => :knowledge_sharing
  get '/admin/local_network_resources' => 'admin/local_networks#edit_resources', :as => :local_network_resources

  # These need to come before resources :pages
  get '/admin/pages/:id/edit'   => 'admin/pages#edit', as: :edit_page
  put '/admin/page/:id.:format' => 'admin/pages#update', as: :update_page
  post '/admin/page/:id/edit'   => 'admin/pages#edit'
  get '/admin/pages/find'       => 'admin/pages#find_by_path_and_redirect_to_latest', as: :find_page_by

  namespace :admin do
    resources :events do
      member do
        post :approve
        post :revoke
      end
    end

    resources :sponsors

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

  # Salesforce webook routes
  namespace :salesforce, defaults: { format: 'json' } do
    post '/sync' => 'api#sync'
  end

  namespace :redesign, path: '/', constraints: RedesignConstraint.new do
    namespace :admin, path: '/redesign/admin' do
      namespace :api, format: :json do
        resources :layouts, only: [:index, :show]
        resources :contacts, only: [:ungc] do
          get :ungc, on: :collection
        end
        resources :events, only: [:index]
        resources :taggings, only: [:topics, :issues, :sectors] do
          get :topics, on: :collection
          get :issues, on: :collection
          get :sectors, on: :collection
        end
        resources :images do
          post :signed_url, on: :collection
        end
        resources :resources, only: [:index]
        resources :initiatives, only: [:index]
        resources :containers do
          post :publish, on: :member
          get :needs_approval, on: :collection
        end
        resources :payloads
      end

      get '/(*path)' => 'index#frontend', as: :root, format: :html
    end

    controller :library do
      get '/library'        => :index,  as: :library
      get '/library/search' => :search, as: :library_search
      get '/library/:id'    => :show,   as: :library_resource
    end

    controller :contact_us do
      get '/about/contact' => :new, as: :new_contact_us
      post '/about/contact' => :create, as: :contact_us
    end

    controller :case_example do
      get '/take-action/action/share-story' => :new, as: :new_case_example
      post '/take-action/action/share-story' => :create, as: :case_example
    end

    controller :all_our_work, path: '/what-is-gc/our-work' do
      get '/all' => :index, as: :all_our_work
    end

    controller :actions do
      get '/take-action/action' => :index, as: :actions
    end

    controller :participant_search, path: '/what-is-gc/participants' do
      get '/' => :index
      get '/search' => :search, as: :participant_search
    end

    resources :participants, path: '/what-is-gc/participants/', only: [:show]

    controller :news, path: '/news' do
      get '/' => :index, as: :news_index
      get '/:id' => :show, constraints: { id: /\d+.*/ }, as: :news
      get '/press-releases' => :press_releases
    end

    controller :events, path: '/take-action/events' do
      get '/' => :index, as: :events
      get '/:id' => :show, constraints: { id: /\d+.*/ }, as: :event
    end

    controller :networks do
      get '/engage-locally/:region/:network' => :show, as: :networks_show , constraints: { region: /africa|asia|europe|latin-america|mena|north-america|oceania/ }
    end

    controller :signup, path: '/participation/join/application/' do
      get   '/step1/:org_type'  => 'signup#step1', :as => :organization_step1
      match '/step2'            => 'signup#step2', :as => :organization_step2, via: [:get, :post]
      match '/step3'            => 'signup#step3', :as => :organization_step3, via: [:get, :post]
      match '/step4'            => 'signup#step4', :as => :organization_step4, via: [:get, :post]
      match '/step5'            => 'signup#step5', :as => :organization_step5, via: [:get, :post]
      match '/step6'            => 'signup#step6', :as => :organization_step6, via: [:get, :post]
      post  '/step7'            => 'signup#step7', :as => :organization_step7
    end

    get '/participation/report/coe/create-and-submit/submitted-coe' => "cops#submitted_coe"
    get '/participation/report/coe/create-and-submit/submitted-coe/:id' => "cops#show", as: :coe
    resource :cops, path: '/participation/report/cop/create-and-submit' do
      get :index, path: '/', on: :collection
      get :show, path: '/:differentiation/:id', as: :show
      get :active, on: :collection
      get :advanced, on: :collection
      get :expelled, on: :collection
      get :learner, on: :collection
      get :non_communicating, on: :collection, path: '/non-communicating'
    end

    get '/search'   => 'search#search',     as: :search

    get '/'         => 'static#home',       as: :root
    get '/404'      => 'static#not_found',  as: :not_found

    # REDIRECTS
    get '/Issues/index.html' => "static#redirect_to_page", page: '/take-action'
    get '/NetworksAroundTheWorld/index.html' => 'static#redirect_to_page', page: '/engage-locally'
    get '/AboutTheGC/tools_resources/index.html' => 'static#redirect_to_page', page: '/library'
    get '/AboutTheGC/global_compact_strategy.html' => 'static#redirect_to_page', page: '/what-is-gc/strategy'
    get '/AboutTheGC/TheTenPrinciples/index.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles'
    get '/AboutTheGC/TheTenPrinciples/Principle1.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-1'
    get '/AboutTheGC/TheTenPrinciples/Principle2.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-2'
    get '/AboutTheGC/TheTenPrinciples/Principle3.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-3'
    get '/AboutTheGC/TheTenPrinciples/Principle4.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-4'
    get '/AboutTheGC/TheTenPrinciples/Principle5.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-5'
    get '/AboutTheGC/TheTenPrinciples/Principle6.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-6'
    get '/AboutTheGC/TheTenPrinciples/Principle7.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-7'
    get '/AboutTheGC/TheTenPrinciples/Principle8.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-8'
    get '/AboutTheGC/TheTenPrinciples/Principle9.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-9'
    get '/AboutTheGC/TheTenPrinciples/Principle10.html' => 'static#redirect_to_page', page: '/what-is-gc/mission/principles/principle-10'
    get '/AboutTheGC/IntegrityMeasures/index.html' => 'static#redirect_to_page', page: '/what-is-gc/our-commitment'
    get '/ParticipantsAndStakeholders/index.html' => 'static#redirect_to_page', page: '/what-is-gc/participants'
    get '/participants/search' => 'static#redirect_to_page', page: '/what-is-gc/participants'
    get '/participant/:id', to: redirect('/what-is-gc/participants/%{id}')
    get '/Issues/supply_chain/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/supply-chain'
    get '/Issues/supply_chain/advisory_group.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/supply-chain/supply-chain-advisory-group'
    get '/Issues/supply_chain/background.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/supply-chain/business-case'
    get '/Issues/partnerships/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/sustainable-development'
    get '/Issues/partnerships/post_2015_development_agenda.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/sustainable-development/background'
    get '/Issues/financial_markets/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/financial'
    get '/Issues/transparency_anticorruption/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/governance/anti-corruption'
    get '/Issues/transparency_anticorruption/collective_action.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/governance/anti-corruption/collective-action'
    get '/Issues/human_rights/business_for_the_rule_of_law.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/governance/rule-law'
    get '/Issues/Environment/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/environment'
    get '/Issues/human_rights/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/social/human-rights'
    get '/Issues/Labour/index.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/social/labour'
    get '/Issues/human_rights/indigenous_peoples_rights.html'=> 'static#redirect_to_page', page: '/what-is-gc/our-work/social/indigenous-people'
    get '/HowToParticipate/index.html' => "static#redirect_to_page", page: '/participation'
    get '/HowToParticipate/Business_Participation/index.html'=> 'static#redirect_to_page', page: '/participation'
    get '/HowToParticipate/cities.html'=> 'static#redirect_to_page', page: '/participation'
    get '/HowToParticipate/civil_society/index.html'=> 'static#redirect_to_page', page: '/participation'
    get '/HowToParticipate/academic_network/index.html'=> 'static#redirect_to_page', page: '/participation'
    get '/HowToParticipate/business_associations.html'=> 'static#redirect_to_page', page: '/participation'
    get '/HowToParticipate/non_business_participation/public_sector_organization.html'=> 'static#redirect_to_page', page: '/participation'
    get '/HowToParticipate/How_To_Apply.html'=> 'static#redirect_to_page', page: '/participation/join/application'
    get '/HowToParticipate/How_to_Apply_Business.html'=> 'static#redirect_to_page', page: '/participation/join/application/business'
    get '/HowToParticipate/How_to_Apply_NonBusiness.html'=> 'static#redirect_to_page', page: '/participation/join/application/non-business'
    get '/COP/COE.html'=> 'static#redirect_to_page', page: '/participation/report/coe'
    get '/COP/COE/submitted_coes.html'=> 'static#redirect_to_page', page: '/participation/report/coe/create-and-submit/submitted-coe'
    get '/COP/index.html'=> 'static#redirect_to_page', page: '/participation/report/cop'
    get '/COP/making_progress/index.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit'
    get '/COP/communicating_progress/how_to_submit_a_cop.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit'
    get '/COP/frequently_asked_questions.html'=> 'static#redirect_to_page', page: '/participation/report/cop'
    get '/COP/analyzing_progress/index.html'=> 'static#redirect_to_page', page: '/participation/report/cop'
    get '/COP/analyzing_progress/expelled_participants.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit/expelled'
    get '/participants/expelled/:id', to: redirect('/participation/report/cop/create-and-submit/expelled/%{id}')
    get '/COP/analyzing_progress/non_communicating.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit/non-communicating'
    get '/participants/noncommunicating/:id', to: redirect('/participation/report/cop/create-and-submit/non-communicating/%{id}')
    get '/COP/analyzing_progress/learner_cops.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit/learner'
    get '/COPs/learner/:id', to: redirect('/participation/report/cop/create-and-submit/learner/%{id}')
    get '/COP/analyzing_progress/active_cops.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit/active'
    get '/COPs/active/:id', to: redirect('/participation/report/cop/create-and-submit/active/%{id}')
    get '/COP/analyzing_progress/advanced_cops.html'=> 'static#redirect_to_page', page: '/participation/report/cop/create-and-submit/advanced'
    get '/COPs/advanced/:id', to: redirect('/participation/report/cop/create-and-submit/advanced/%{id}')

    # CATCH ALL
    get '*path'     => 'static#catch_all',  as: :catch_all
  end

  root :to => 'pages#home'
  resources :organizations, :only => :index


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
  get ':gc15' => 'pages#redirect_to_page', :page => '/NewsAndEvents/global_compact_15.html', :constraints => { :gc15 => /gc15/i }

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
