require 'ckeditor'
require 'sidekiq/web'

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

      resources :communication_on_progresses, :controller => 'cops' do
        resources :files, :controller => 'cop_files', only: [:index, :new, :create, :destroy]
        member do
          get  :backdate
          post :do_backdate
          get :edit_draft
        end
      end

      resources :grace_letters, except: :index
      resources :reporting_cycle_adjustments, except: :index

      resources :contacts do
        member do
          post :reset_password
        end
      end
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
      resources :contacts do
        member do
          post :reset_password, as: :reset_password
        end
      end
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

    controller :sign_in_as, path: '/sign-in-as' do
      get '/contacts' => :index, as: :sign_in_as_contacts, defaults: { format: 'json' }
      get '/' => :create, as: :sign_in_as
    end

  end

  # public api
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      get 'contributors' => 'contributors#index'
      get 'contributors/:year' => 'contributors#show'

      namespace :autocomplete do
        get :participants
        get :countries
        get :sdg_pioneer_businesses
      end

    end
  end

  # Salesforce webook routes
  namespace :salesforce, defaults: { format: 'json' } do
    post '/sync' => 'api#sync'
  end

  namespace :sitemap, path: '/sitemap' do
    namespace :api, format: :json do
      resources :layouts, only: [:index, :show]
      resources :contacts, only: [:index, :current] do
        get :current, on: :collection
      end
      resources :events, only: [:index]
      resources :taggings, only: [:topics, :issues, :sectors, :sustainable_development_goals] do
        get :topics, on: :collection
        get :issues, on: :collection
        get :sectors, on: :collection
        get :sustainable_development_goals, on: :collection
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

  controller :library, path: 'library' do
    get ''                                        => :index,  as: :library
    get 'search'                                  => :search, as: :library_search
    get 'blueprint-for-corporate-sustainability'  => :blueprint_for_corporate_sustainability
    get 'advanced-cop-submission-guide'           => :advanced_cop_submission_guide
    get ':id'                                     => :show,   as: :library_resource
    post 'link_views'                              => :link_views, as: :library_link_views
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
  get '/feeds/news' => 'news#press_releases', :format => 'atom'

  controller :events, path: '/take-action/events' do
    get '/' => :index, as: :events
    get '/:id' => :show, constraints: { id: /\d+.*/ }, as: :event
  end

  controller :networks, path: '/engage-locally' do
    get '/:region' => :region, as: :networks_region , constraints: { region: /africa|asia|europe|latin-america|mena|north-america|oceania/ }
    get '/:region/:network' => :show, as: :networks_show , constraints: { region: /africa|asia|europe|latin-america|mena|north-america|oceania/ }
  end

  controller :signup, path: '/participation/join/application/' do
    get   '/'                 => 'signup#index', :as => :signup
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
  get '/feeds/cops' => 'cops#feed', :format => 'atom'

  resources :organizations, :only => :index

  get '/photo-credits' => "images#index", as: :photo_credits

  get '/search'   => 'search#search',     as: :search

  get '/'         => 'static#home',       as: :root
  get '/layout-sample' => 'static#layout_sample', as: :layout_sample

  namespace :sdg_pioneer, path: '/what-is-gc/our-work/sustainable-development/sdgpioneers' do
    get :index, path: '/'
    resources :businesses, path: 'local-business-leaders', only: [:new, :create]
    resources :individuals, path: 'local-change-makers', only: [:new, :create]
    resources :others, path: 'nomination-form', only: [:new, :create]
  end

  # REDIRECTS
  get '/AboutTheGC/global_compact_strategy.html', to: redirect('/what-is-gc/strategy')
  get '/AboutTheGC/TheTenPrinciples/index.html', to: redirect('/what-is-gc/mission/principles')
  get '/AboutTheGC/TheTenPrinciples/Principle1.html', to: redirect('/what-is-gc/mission/principles/principle-1')
  get '/AboutTheGC/TheTenPrinciples/Principle2.html', to: redirect('/what-is-gc/mission/principles/principle-2')
  get '/AboutTheGC/TheTenPrinciples/Principle3.html', to: redirect('/what-is-gc/mission/principles/principle-3')
  get '/AboutTheGC/TheTenPrinciples/Principle4.html', to: redirect('/what-is-gc/mission/principles/principle-4')
  get '/AboutTheGC/TheTenPrinciples/Principle5.html', to: redirect('/what-is-gc/mission/principles/principle-5')
  get '/AboutTheGC/TheTenPrinciples/Principle6.html', to: redirect('/what-is-gc/mission/principles/principle-6')
  get '/AboutTheGC/TheTenPrinciples/Principle7.html', to: redirect('/what-is-gc/mission/principles/principle-7')
  get '/AboutTheGC/TheTenPrinciples/Principle8.html', to: redirect('/what-is-gc/mission/principles/principle-8')
  get '/AboutTheGC/TheTenPrinciples/Principle9.html', to: redirect('/what-is-gc/mission/principles/principle-9')
  get '/AboutTheGC/TheTenPrinciples/Principle10.html', to: redirect('/what-is-gc/mission/principles/principle-10')
  get '/AboutTheGC/IntegrityMeasures/index.html', to: redirect('/about/integrity-measures')
  get '/ParticipantsAndStakeholders/index.html', to: redirect('/what-is-gc/participants')
  get '/participants/search', to: redirect('/what-is-gc/participants')
  get '/participant/:id', to: redirect('/what-is-gc/participants/%{id}')
  get '/HowToParticipate/Business_Participation/blueprint_for_corporate_sustainability_leadership.html', to: redirect('/library/blueprint-for-corporate-sustainability')
  get '/Issues/supply_chain/index.html', to: redirect('/what-is-gc/our-work/supply-chain')
  get '/Issues/supply_chain/advisory_group.html', to: redirect('/what-is-gc/our-work/supply-chain/supply-chain-advisory-group')
  get '/Issues/supply_chain/background.html', to: redirect('/what-is-gc/our-work/supply-chain/business-case')
  get '/Issues/partnerships/index.html', to: redirect('/take-action/partnerships')
  get '/Issues/partnerships/post_2015_development_agenda.html', to: redirect('/what-is-gc/our-work/sustainable-development/')
  get '/Issues/financial_markets/index.html', to: redirect('/what-is-gc/our-work/financial')
  get '/Issues/transparency_anticorruption/index.html', to: redirect('/what-is-gc/our-work/governance/anti-corruption')
  get '/Issues/transparency_anticorruption/collective_action.html', to: redirect('/take-action/action/anti-corruption-collective-action')
  get '/Issues/Environment/index.html', to: redirect('/what-is-gc/our-work/environment')
  get '/Issues/human_rights/index.html', to: redirect('/what-is-gc/our-work/social/human-rights')
  get '/Issues/human_rights/Human_Rights_Working_Group.html', to: redirect('/what-is-gc/our-work/social/human-rights/working-group')
  get '/Issues/Labour/index.html', to: redirect('/what-is-gc/our-work/social/labour')
  get '/Issues/human_rights/indigenous_peoples_rights.html', to: redirect('/what-is-gc/our-work/social/indigenous-people')
  get '/HowToParticipate/index.html', to: redirect('/participation')
  get '/HowToParticipate/Business_Participation/index.html', to: redirect('/participation/join')
  get '/HowToParticipate/cities.html', to: redirect('/participation/join/who-should-join/non-business')
  get '/HowToParticipate/civil_society/index.html', to: redirect('/participation/join/who-should-join/non-business')
  get '/HowToParticipate/academic_network/index.html', to: redirect('/participation/join/who-should-join/non-business')
  get '/HowToParticipate/business_associations.html', to: redirect('/participation/join/who-should-join/non-business')
  get '/HowToParticipate/non_business_participation.html', to: redirect('/participation/join/application')
  get '/HowToParticipate/non_business_participation/public_sector_organization.html', to: redirect('/participation/join/who-should-join/non-business')
  get '/HowToParticipate/How_To_Apply.html', to: redirect('/participation/join/application')
  get '/HowToParticipate/How_to_Apply_Business.html', to: redirect('/participation/join/application/business')
  get '/HowToParticipate/How_to_Apply_NonBusiness.html', to: redirect('/participation/join/application/non-business')
  get '/COP/COE.html', to: redirect('/participation/report/coe')
  get '/COP/COE/submitted_coes.html', to: redirect('/participation/report/coe/create-and-submit/submitted-coe')
  get '/COP/index.html', to: redirect('/participation/report/cop')
  get '/COP/making_progress/index.html', to: redirect('/participation/report/cop/create-and-submit')
  get '/COP/communicating_progress/how_to_submit_a_cop.html', to: redirect('/participation/report/cop/create-and-submit')
  get '/COP/frequently_asked_questions.html', to: redirect('/participation/report/cop')
  get '/COP/analyzing_progress/index.html', to: redirect('/participation/report/cop')
  get '/COP/analyzing_progress/expelled_participants.html', to: redirect('/participation/report/cop/create-and-submit/expelled')
  get '/participants/expelled/:id', to: redirect('/participation/report/cop/create-and-submit/expelled/%{id}')
  get '/COP/analyzing_progress/non_communicating.html', to: redirect('/participation/report/cop/create-and-submit/non-communicating')
  get '/participants/noncommunicating/:id', to: redirect('/participation/report/cop/create-and-submit/non-communicating/%{id}')
  get '/COP/analyzing_progress/learner_cops.html', to: redirect('/participation/report/cop/create-and-submit/learner')
  get '/COPs/learner/:id', to: redirect('/participation/report/cop/create-and-submit/learner/%{id}')
  get '/COP/analyzing_progress/active_cops.html', to: redirect('/participation/report/cop/create-and-submit/active')
  get '/COPs/active/:id', to: redirect('/participation/report/cop/create-and-submit/active/%{id}')
  get '/COP/analyzing_progress/advanced_cops.html', to: redirect('/participation/report/cop/create-and-submit/advanced')
  get '/COPs/advanced/:id', to: redirect('/participation/report/cop/create-and-submit/advanced/%{id}')
  get '/COPs/detail/:id', to: redirect('/participation/report/cop/create-and-submit/detail/%{id}')
  get '/COP/differentiation/GCAdvanced_level.html', to: redirect('/library/advanced-cop-submission-guide')
  get '/AboutTheGC/Global_Compact_Logo/index.html', to: redirect('/participation/getting-started/brand-guidelines')
  get '/AboutTheGC/Global_Compact_Logo/GC_Logo_Policy.html', to: redirect('/participation/getting-started/brand-guidelines')
  get '/AboutTheGC/guide_to_corporate_sustainability.html', to: redirect('/library/1151')
  get '/Issues/index.html', to: redirect('/what-is-gc/our-work/')
  get '/HowToParticipate/Lead/index.html', to: redirect('/take-action/leadership/gc-lead')
  get '/HowToParticipate/Lead/participation.html', to: redirect('/take-action/leadership/gc-lead')
  get '/HowToParticipate/Lead/lead_participants.html', to: redirect('/what-is-gc/participants')
  get '/HowToParticipate/Lead/LEADactivities.html', to: redirect('/take-action/leadership/gc-lead/projects')
  get '/HowToParticipate/Engagement_Opportunities/index.html', to: redirect('/take-action/action')
  get '/Issues/conflict_prevention/local_network_activities.html', to: redirect('/take-action/action/peace-local-activities')
  get '/Issues/Labour/child_labour_platform.html', to: redirect('/take-action/action/child-labour')
  get '/Issues/conflict_prevention/index.html', to: redirect('/take-action/action/peace')
  get '/Issues/Environment/food_agriculture_business_principles.html', to: redirect('/take-action/action/food')
  get '/Issues/human_rights/childrens_principles.html', to: redirect('/take-action/action/child-rights')
  get '/Issues/human_rights/equality_means_business.html', to: redirect('/take-action/action/womens-principles')
  get '/Issues/Environment/CEO_Water_Mandate/index.html', to: redirect('/take-action/action/water-mandate')
  get '/Issues/Environment/Climate_Change/index.html', to: redirect('/take-action/action/climate')
  get '/HowToParticipate/Lead/board_programme.html', to: redirect('/take-action/action/gc-board-programme')
  get '/Issues/financial_markets/value_driver_model.html', to: redirect('/take-action/action/value-driver-model')
  get '/Issues/human_rights/business_for_the_rule_of_law.html', to: redirect('/take-action/action/business-rule-of-law')
  get '/Issues/transparency_anticorruption/call_to_action_post2015.html', to: redirect('/take-action/action/anti-corruption-call-to-action')
  get '/Issues/transparency_anticorruption/working_group.html', to: redirect('/take-action/action/anti-corruption-working-group')
  get '/Issues/human_rights/Human_Rights_Dilemmas_Forum.html', to: redirect('/take-action/action/business-dilemmas-forum')
  get '/Issues/financial_markets/global_compact_100.html', to: redirect('/take-action/action/global-compact-100')
  get '/NewsAndEvents/event_calendar/index.html', to: redirect('/take-action/events')
  get '/NetworksAroundTheWorld/Meetings_and_Events.html', to: redirect('/take-action/events')
  get '/Issues/human_rights/Meetings_and_Workshops.html', to: redirect('/take-action/events')
  get '/Issues/Labour/Meetings_and_Workshops.html', to: redirect('/take-action/events')
  get '/Issues/Environment/meetings_and_events.html', to: redirect('/take-action/events')
  get '/Issues/transparency_anticorruption/Anti-Corruption_Meetings_and_Events.html', to: redirect('/take-action/events')
  get '/Issues/conflict_prevention/annual_event.html', to: redirect('/take-action/events')
  get '/Issues/partnerships/Partnerships_for_Development_Meetings_and_Events.html', to: redirect('/take-action/events')
  get '/Issues/Business_Partnerships/meetings_workshops.html', to: redirect('/take-action/events')
  get '/Issues/supply_chain/meetings.html', to: redirect('/take-action/events')
  get '/AboutTheGC/The_Global_Compact_Board/meetings.html', to: redirect('/library/1821')
  get '/NetworksAroundTheWorld/index.html', to: redirect('/engage-locally')
  get '/LocalNetworksResources/engagement_framework/index.html', to: redirect('/engage-locally/manage/engagement')
  get '/LocalNetworksResources/engagement_framework/human_rights_and_labour.html', to: redirect('/engage-locally/manage/engagement/human-rights-and-labour')
  get '/LocalNetworksResources/engagement_framework/childrens_rights_and_business_principles.html', to: redirect('/engage-locally/manage/engagement/childrens-rights-and-business-principles')
  get '/LocalNetworksResources/engagement_framework/womens_empowerment_principles.html', to: redirect('/engage-locally/manage/engagement/womens-empowerment-principles')
  get '/LocalNetworksResources/engagement_framework/caring_for_climate.html', to: redirect('/engage-locally/manage/engagement/caring-for-climate')
  get '/LocalNetworksResources/engagement_framework/ceo_water_mandate.html', to: redirect('/engage-locally/manage/engagement/ceo-water-mandate')
  get '/LocalNetworksResources/engagement_framework/anti_corruption.html', to: redirect('/engage-locally/manage/engagement/anti-corruption')
  get '/LocalNetworksResources/engagement_framework/business_for_peace.html', to: redirect('/engage-locally/manage/engagement/business-for-peace')
  get '/LocalNetworksResources/engagement_framework/supply_chain_sustainability.html', to: redirect('/engage-locally/manage/engagement/supply-chain-sustainability')
  get '/LocalNetworksResources/training_guidance_material/index.html', to: redirect('/engage-locally/manage/training')
  get '/LocalNetworksResources/training_guidance_material/outreach.html', to: redirect('/engage-locally/manage/training')
  get '/LocalNetworksResources/training_guidance_material/cop_training.html', to: redirect('/engage-locally/manage/training')
  get '/LocalNetworksResources/training_guidance_material/partnerships.html', to: redirect('/engage-locally/manage/training')
  get '/LocalNetworksResources/training_guidance_material/fundraising_toolkit.html', to: redirect('/engage-locally/manage/training')
  get '/LocalNetworksResources/training_guidance_material/webinars.html', to: redirect('/engage-locally/manage/training')
  get '/LocalNetworksResources/news_updates/index.html', to: redirect('/engage-locally/manage/news')
  get '/LocalNetworksResources/reports/index.html', to: redirect('/engage-locally/manage/reports')
  get '/LocalNetworksResources/reports/foundation_financial_statements.html', to: redirect('/engage-locally/manage/reports/foundation')
  get '/LocalNetworksResources/reports/outcome_documents.html', to: redirect('/engage-locally/manage/reports/mtg-outcome')
  get '/LocalNetworksResources/reports/local_network_annual_reports.html', to: redirect('/engage-locally/manage/reports/local-network-report')
  get '/LocalNetworksResources/reports/local_network_advisory_group_documents.html', to: redirect('/engage-locally/manage/reports/local-networks-document')
  get '/LocalNetworksResources/reports/un_global_compact_activity_reports.html', to: redirect('/engage-locally/manage/reports/activity-report')
  get '/AboutTheGC/tools_resources/index.html', to: redirect('/library')
  get '/resources', to: redirect('/library')
  get '/AboutTheGC/index.html', to: redirect('/about')
  get '/AboutTheGC/faq.html', to: redirect('/about/faq')
  get '/AboutTheGC/The_GC_Foundation.html', to: redirect('/about/foundation')
  get '/AboutTheGC/Internship_at_the_Global_Compact/index.html', to: redirect('/about/opportunities/internships')
  get '/AboutTheGC/job_opportunities_with_the_global_compact.html', to: redirect('/about/opportunities')
  get '/AboutTheGC/contact_us.html', to: redirect('/about/contact')
  get '/AboutTheGC/stages_of_development.html', to: redirect('/about/governance')
  get '/AboutTheGC/The_Global_Compact_Board/index.html', to: redirect('/about/governance/board')
  get '/AboutTheGC/The_Global_Compact_Board/bios.html', to: redirect('/about/governance/board/members')
  get '/NetworksAroundTheWorld/local_network_advisory_group.html', to: redirect('/about/governance/local-network-advisory-group')
  get '/AboutTheGC/IntegrityMeasures/Integrity_Measures_FAQs.html', to: redirect('/about/integrity-measures')
  get '/AboutTheGC/Government_Support.html', to: redirect('/about/government-recognition')
  get '/AboutTheGC/Government_Support/general_assembly_resolutions.html', to: redirect('/about/government-recognition/general-assembly-resolutions')
  get '/AboutTheGC/Government_Support/recognition_by_the_g8.html', to: redirect('/about/government-recognition/g8-recognition')
  get '/AboutTheGC/Government_Support/outcomes_and_declarations.html', to: redirect('/about/government-recognition/outcomes-declarations')
  get '/NewsAndEvents/index.html', to: redirect('/news')
  get '/NewsAndEvents/UNGC_bulletin/index.html', to: redirect('/news/bulletin')
  get '/NewsAndEvents/UNGC_bulletin/subscribe.html', to: redirect('/news/bulletin')
  get '/NewsAndEvents/UNGC_bulletin/subscribe_email_sent.html', to: redirect('/news/bulletin')
  get '/NewsAndEvents/UNGC_bulletin/unsubscribe.html', to: redirect('/news/bulletin')
  get '/NewsAndEvents/UNGC_bulletin(*path)', to: redirect('/library/search?search[content_type]=4')
  get '/NewsAndEvents/Speeches.html', to: redirect('/news/speeches')
  get '/NewsAndEvents/Global_Compact_in_the_Media.html', to: redirect('/news/media')
  get '/WebsiteInfo/copyright.html', to: redirect('/copyright')
  get '/WebsiteInfo/privacy_policy.html', to: redirect('/privacy-policy')
  get '/NewsAndEvents/media_contacts.html', to: redirect('/about/contact')
  get '/resources/:id', to: redirect('/library/%{id}')
  get '/NetworksAroundTheWorld/local_network_sheet/(:country_code).html'=> 'networks#redirect_to_network'
  get '/languages/spanish/los_diez_principios.html', to: redirect('/what-is-gc/mission/principles')
  get '/Languages/spanish/Los_Diez_Principios.html', to: redirect('/what-is-gc/mission/principles')
  get '/Languages/german/die_zehn_prinzipien.html', to: redirect('/what-is-gc/mission/principles')
  get '/Issues/index.html', to: redirect('/what-is-gc/our-work/all')
  get '/AboutTheGC/global_corporate_sustainability_report.html', to: redirect('/library/371')
  get '/AboutTheGC/TheTenPrinciples/humanRights.html', to: redirect('/what-is-gc/our-work/social/human-rights')
  get '/AboutTheGC/TheTenPrinciples/labour.html', to: redirect('/what-is-gc/our-work/social/labour')
  get '/AboutTheGC/TheTenPrinciples/environment.html', to: redirect('/what-is-gc/our-work/environment')
  get '/AboutTheGC/TheTenPrinciples/anti-corruption.html', to: redirect('/what-is-gc/our-work/governance/anti-corruption')
  get '/Languages(*path)', to: redirect('/')
  get '/languages(*path)', to: redirect('/')
  get '/redesign/admin', to: redirect('/sitemap')
  get '/UNPrivateSectorForum2015', to: redirect('/take-action/events/61-united-nations-private-sector-forum-2015')
  get '/AboutTheGC/tools_resources/', to: redirect('/library')
  get '/NetworksAroundTheWorld/', to: redirect('/engage-locally')
  get '/sdgs/', to: redirect('/what-is-gc/our-work/sustainable-development/sdgs/17-global-goals')
  get '/COP/making_progress/advanced.html', to: redirect('/participation/report/cop/create-and-submit/advanced')
  get '/leaderssummit', to: redirect('/take-action/events/411-un-global-compact-leaders-summit-2016')
  get '/leaderssummit2016', to: redirect('/take-action/events/411-un-global-compact-leaders-summit-2016')
  get '/sdgpioneers', to: redirect('/what-is-gc/our-work/sustainable-development/sdgpioneers')
  get '/SDGpioneers', to: redirect('/what-is-gc/our-work/sustainable-development/sdgpioneers')
  get '/pioneers', to: redirect('/what-is-gc/our-work/sustainable-development/sdgpioneers')
  get '/what-is-gc/our-work/sustainable-development/17-global-goals', to: redirect('/what-is-gc/our-work/sustainable-development/sdgs/17-global-goals')

  # new redirects (to be tested)
  get '/index.html', to: redirect('/')
  get '/NewsAndEvents/global_compact_15.html', to: redirect('/take-action/events/31-global-compact-15-business-as-a-force-for-good')
  get '/aboutthegc/thetenprinciples(*path)', to: redirect('/what-is-gc/mission/principles')
  get '/AboutTheGC/TheTenPrinciples/principle1.html', to: redirect('/what-is-gc/mission/principles/principle-1')
  get '/participantsandstakeholders/civil_society.html', to: redirect('/what-is-gc/participants')
  get '/NewsAndEvents/event_calendar/index.html', to: redirect('/take-action/events')
  get '/COP/communicating_progress/basic_cop_template.html', :to => redirect('/library/2971')


  # google links
  get '/aboutthegc', to: redirect('/what-is-gc')
  get '/howtoparticipate/How_To_Apply.html', to: redirect('/participation/join/application')
  get '/ParticipantsandStakeholders/index.html', to: redirect('/what-is-gc/participants')
  get '/issues/human_rights/', to: redirect('/what-is-gc/our-work/social/human-rights')
  get '/HowToParticipate/academic_network/', to: redirect('/participations/join/who-should-join/non-business')
  get '/aboutthegc/contact_us.html', to: redirect('/about/contact')
  get '/howtoparticipate/business_participation/index.html', to: redirect('/participation/join')
  get '/newsandevents/event_calendar/webinars.html', to: redirect('/take-action/events')
  get '/NewsAndEvents/event_calendar/webinars.html', to: redirect('/take-action/events')
  get '/Issues/financial_markets/global_compact_100.html', to: redirect('/take-action/action/global-compact-100')
  get '/sdgpioneers', to: redirect('/what-is-gc/our-work/sustainable-development/sdgpioneers')
  get '/SDGpioneers', to: redirect('/what-is-gc/our-work/sustainable-development/sdgpioneers')
  get '/pioneers', to: redirect('/what-is-gc/our-work/sustainable-development/sdgpioneers')

  # old redirects porting
  get '/climate', to: redirect('/what-is-gc/our-work/environment/climate')
  get '/watermandate', to: redirect('/take-action/action/water-mandate')
  get '/weps', to: redirect('/what-is-gc/our-work/social/gender-equality')
  get '/networks', to: redirect('/engage-locally')
  get '/rio_resources', to: redirect('/library/1041')
  get '/leadlab', to: redirect('http://leadlab.unglobalcompact.org/')
  get ':lead', to: redirect('/take-action/leadership/gc-lead'), :constraints => { :lead => /lead/i }
  get '/LEADBoardProgramme', to: redirect('/take-action/action/gc-board-programme')
  get ':boardprogramme', to: redirect('/take-action/action/gc-board-programme'), :constraints => { :boardprogramme => /boardprogramme/i }
  get '/app', to: redirect('http://ungcevents.quickmobile.mobi/')
  get '/businesspartnershiphub', to: redirect('http://businesspartnershiphub.org/')
  get '/HR_Resources', to: redirect('/docs/issues_doc/human_rights/Resources/HR_Postcard.pdf')
  get ':fabprinciples', to: redirect('/what-is-gc/our-work/environment/food-agriculture'), :constraints => { :fabprinciples => /fabprinciples/i }
  get '/ActionFair', to: redirect('/docs/news_events/upcoming/ActionFairSources.pdf')
  get '/lnw', to: redirect('/engage-locally')
  get '/FundraisingToolkit', to: redirect('/docs/networks_around_world_doc/LN_Fundraising_Toolkit.pdf')
  get '/anti-corruption', to: redirect('/take-action/action/anti-corruption-call-to-action')
  get '/UNPrivateSectorForum', to: redirect('/library/1221')
  get '/LEADSymposium', to: redirect('/take-action/events/51-2015-lead-symposium')
  get ':leadsymposiumonline', to: redirect('http://un.banks-sadler.com'), :constraints => { :leadsymposiumonline => /leadsymposiumonline/i }
  get ':gc15', to: redirect('/take-action/events/31-global-compact-15-business-as-a-force-for-good'), :constraints => { :gc15 => /gc15/i }
  get '/HowToParticipate/Organization_Information.html', to: redirect('/participation/join/application/non-business')
  get '/Issues/conflict_prevention/', to: redirect('/what-is-gc/our-work/governance/peace')

  # ensure the rails mailers paths don't get caught in the catch_all
  get '/rails/mailers' => "rails/mailers#index"
  get '/rails/mailers/*path' => "rails/mailers#preview"

  # CATCH ALL
  get '*path'     => 'static#catch_all',  as: :catch_all, :constraints => { :format => 'html' }

  mount Ckeditor::Engine => "/ckeditor"
end
