desc 'sadness'

task :redirect_test do
  RedirectTest.new.run
end

class RedirectTest
  def initialize
    @dev_host = 'http://localhost:5000'
    @conn = Faraday.new(url: @dev_host)

    @urls_to_redirect = [
      {old: '/NetworksAroundTheWorld/index.html', new: '/engage-locally'},
      {old: '/AboutTheGC/tools_resources/index.html', new: '/library'},
      {old: '/AboutTheGC/global_compact_strategy.html', new: '/what-is-gc/strategy'},
      {old: '/AboutTheGC/TheTenPrinciples/index.html', new: '/what-is-gc/mission/principles'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle1.html', new: '/what-is-gc/mission/principles/principle-1'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle2.html', new: '/what-is-gc/mission/principles/principle-2'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle3.html', new: '/what-is-gc/mission/principles/principle-3'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle4.html', new: '/what-is-gc/mission/principles/principle-4'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle5.html', new: '/what-is-gc/mission/principles/principle-5'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle6.html', new: '/what-is-gc/mission/principles/principle-6'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle7.html', new: '/what-is-gc/mission/principles/principle-7'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle8.html', new: '/what-is-gc/mission/principles/principle-8'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle9.html', new: '/what-is-gc/mission/principles/principle-9'},
      {old: '/AboutTheGC/TheTenPrinciples/Principle10.html', new: '/what-is-gc/mission/principles/principle-10'},
      {old: '/AboutTheGC/IntegrityMeasures/index.html', new: '/what-is-gc'},
      {old: '/ParticipantsAndStakeholders/index.html', new: '/what-is-gc/participants'},
      {old: '/participants/search', new: '/what-is-gc/participants'},
      {old: '/participant/9625-UNGC', new: '/what-is-gc/participants/9625-UNGC'},
      {old: '/Issues/supply_chain/index.html', new: '/what-is-gc/our-work/supply-chain'},
      {old: '/Issues/supply_chain/advisory_group.html', new: '/what-is-gc/our-work/supply-chain/supply-chain-advisory-group'},
      {old: '/Issues/supply_chain/background.html', new: '/what-is-gc/our-work/supply-chain/business-case'},
      {old: '/Issues/partnerships/index.html', new: '/what-is-gc/our-work/sustainable-development'},
      {old: '/Issues/partnerships/post_2015_development_agenda.html', new: '/what-is-gc/our-work/sustainable-development/background'},
      {old: '/Issues/financial_markets/index.html', new: '/what-is-gc/our-work/financial'},
      {old: '/Issues/transparency_anticorruption/index.html', new: '/what-is-gc/our-work/governance/anti-corruption'},
      {old: '/Issues/transparency_anticorruption/collective_action.html', new: '/what-is-gc/our-work/governance/anti-corruption'},
      {old: '/Issues/human_rights/business_for_the_rule_of_law.html', new: '/what-is-gc/our-work/governance/rule-law'},
      {old: '/Issues/Environment/index.html', new: '/what-is-gc/our-work/environment'},
      {old: '/Issues/human_rights/index.html', new: '/what-is-gc/our-work/social/human-rights'},
      {old: '/Issues/Labour/index.html', new: '/what-is-gc/our-work/social/labour'},
      {old: '/Issues/human_rights/indigenous_peoples_rights.html', new: '/what-is-gc/our-work/social/indigenous-people'},
      {old: '/HowToParticipate/index.html', new: '/participation'},
      {old: '/HowToParticipate/Business_Participation/index.html', new: '/participation'},
      {old: '/HowToParticipate/cities.html', new: '/participation'},
      {old: '/HowToParticipate/civil_society/index.html', new: '/participation'},
      {old: '/HowToParticipate/academic_network/index.html', new: '/participation'},
      {old: '/HowToParticipate/business_associations.html', new: '/participation'},
      {old: '/HowToParticipate/non_business_participation/public_sector_organization.html', new: '/participation'},
      {old: '/HowToParticipate/How_To_Apply.html', new: '/participation/join/application'},
      {old: '/HowToParticipate/How_to_Apply_Business.html', new: '/participation/join/application/business'},
      {old: '/HowToParticipate/How_to_Apply_NonBusiness.html', new: '/participation/join/application/non-business'},
      {old: '/COP/COE.html', new: '/participation/report/coe'},
      {old: '/COP/COE/submitted_coes.html', new: '/participation/report/coe/create-and-submit/submitted-coe'},
      {old: '/COP/index.html', new: '/participation/report/cop'},
      {old: '/COP/making_progress/index.html', new: '/participation/report/cop/create-and-submit'},
      {old: '/COP/communicating_progress/how_to_submit_a_cop.html', new: '/participation/report/cop/create-and-submit'},
      {old: '/COP/frequently_asked_questions.html', new: '/participation/report/cop'},
      {old: '/COP/analyzing_progress/index.html', new: '/participation/report/cop'},
      {old: '/COP/analyzing_progress/expelled_participants.html', new: '/participation/report/cop/create-and-submit/expelled'},
      {old: '/participants/expelled/16849-ROSNI-s-r-o-', new: '/participation/report/cop/create-and-submit/expelled/16849-ROSNI-s-r-o-'},
      {old: '/COP/analyzing_progress/non_communicating.html', new: '/participation/report/cop/create-and-submit/non-communicating'},
      {old: '/participants/noncommunicating/2638-Creat-Group-Co-Ltd-', new: '/participation/report/cop/create-and-submit/non-communicating/2638-Creat-Group-Co-Ltd-'},
      {old: '/COP/analyzing_progress/learner_cops.html', new: '/participation/report/cop/create-and-submit/learner'},
      {old: '/COPs/learner/143231', new: '/participation/report/cop/create-and-submit/learner/143231'},
      {old: '/COP/analyzing_progress/active_cops.html', new: '/participation/report/cop/create-and-submit/active'},
      {old: '/COPs/active/143311', new: '/participation/report/cop/create-and-submit/active/143311'},
      {old: '/COP/analyzing_progress/advanced_cops.html', new: '/participation/report/cop/create-and-submit/advanced'},
      {old: '/COPs/advanced/143311', new: '/participation/report/cop/create-and-submit/advanced/143311'},
      {old: '/Issues/index.html', new: '/take-action'},
      {old: '/HowToParticipate/Lead/index.html', new: '/take-action/leadership'},
      {old: '/HowToParticipate/Lead/participation.html', new: '/take-action/leadership/gc-lead'},
      {old: '/HowToParticipate/Lead/LEADactivities.html', new: '/take-action/leadership/gc-lead/projects'},
      {old: '/HowToParticipate/Engagement_Opportunities/index.html', new: '/take-action/action'},
      {old: '/Issues/Labour/child_labour_platform.html', new: '/take-action/action/child-labour'},
      {old: '/Issues/conflict_prevention/index.html', new: '/take-action/action/peace'},
      {old: '/Issues/Environment/food_agriculture_business_principles.html', new: '/take-action/action/food'},
      {old: '/Issues/human_rights/childrens_principles.html', new: '/take-action/action/child-rights'},
      {old: '/Issues/human_rights/equality_means_business.html', new: '/take-action/action/womens-principles'},
      {old: '/Issues/Environment/CEO_Water_Mandate/index.html', new: '/take-action/action/water-mandate'},
      {old: '/Issues/Environment/Climate_Change/index.html', new: '/take-action/action/climate'},
      {old: '/HowToParticipate/Lead/board_programme.html', new: '/take-action/action/gc-board-programme'},
      {old: '/Issues/financial_markets/value_driver_model.html', new: '/take-action/action/value-driver-model'},
      {old: '/Issues/transparency_anticorruption/call_to_action_post2015.html', new: '/take-action/action/anti-corruption-call-to-action'},
      {old: '/Issues/transparency_anticorruption/working_group.html', new: '/take-action/action/anti-corruption-working-group'},
      {old: '/Issues/human_rights/Human_Rights_Dilemmas_Forum.html', new: '/take-action/action/business-dilemmas-forum'},
      {old: '/Issues/financial_markets/global_compact_100.html', new: '/take-action/action/global-compact-100'},
      {old: '/NewsAndEvents/event_calendar/index.html', new: '/take-action/events'},
      {old: '/NetworksAroundTheWorld/Meetings_and_Events.html', new: '/take-action/events'},
      {old: '/Issues/human_rights/Meetings_and_Workshops.html', new: '/take-action/events'},
      {old: '/Issues/Labour/Meetings_and_Workshops.html', new: '/take-action/events'},
      {old: '/Issues/Environment/meetings_and_events.html', new: '/take-action/events'},
      {old: '/Issues/transparency_anticorruption/Anti-Corruption_Meetings_and_Events.html', new: '/take-action/events'},
      {old: '/Issues/conflict_prevention/annual_event.html', new: '/take-action/events'},
      {old: '/Issues/partnerships/Partnerships_for_Development_Meetings_and_Events.html', new: '/take-action/events'},
      {old: '/Issues/Business_Partnerships/meetings_workshops.html', new: '/take-action/events'},
      {old: '/Issues/supply_chain/meetings.html', new: '/take-action/events'},
      {old: '/AboutTheGC/The_Global_Compact_Board/meetings.html', new: '/take-action/events'},
      {old: '/NetworksAroundTheWorld/index.html', new: '/engage-locally'},
      {old: '/LocalNetworksResources/engagement_framework/index.html', new: '/engage-locally/manage/engagement'},
      {old: '/LocalNetworksResources/engagement_framework/human_rights_and_labour.html', new: '/engage-locally/manage/engagement/human-rights-and-labour'},
      {old: '/LocalNetworksResources/engagement_framework/childrens_rights_and_business_principles.html', new: '/engage-locally/manage/engagement/childrens-rights-and-business-principles'},
      {old: '/LocalNetworksResources/engagement_framework/womens_empowerment_principles.html', new: '/engage-locally/manage/engagement/womens-empowerment-principles'},
      {old: '/LocalNetworksResources/engagement_framework/caring_for_climate.html', new: '/engage-locally/manage/engagement/caring-for-climate'},
      {old: '/LocalNetworksResources/engagement_framework/ceo_water_mandate.html', new: '/engage-locally/manage/engagement/ceo-water-mandate'},
      {old: '/LocalNetworksResources/engagement_framework/anti_corruption.html', new: '/engage-locally/manage/engagement/anti-corruption'},
      {old: '/LocalNetworksResources/engagement_framework/business_for_peace.html', new: '/engage-locally/manage/engagement/business-for-peace'},
      {old: '/LocalNetworksResources/engagement_framework/supply_chain_sustainability.html', new: '/engage-locally/manage/engagement/supply-chain-sustainability'},
      {old: '/LocalNetworksResources/training_guidance_material/index.html', new: '/engage-locally/manage/training'},
      {old: '/LocalNetworksResources/training_guidance_material/outreach.html', new: '/engage-locally/manage/training'},
      {old: '/LocalNetworksResources/training_guidance_material/cop_training.html', new: '/engage-locally/manage/training'},
      {old: '/LocalNetworksResources/training_guidance_material/partnerships.html', new: '/engage-locally/manage/training'},
      {old: '/LocalNetworksResources/training_guidance_material/fundraising_toolkit.html', new: '/engage-locally/manage/training'},
      {old: '/LocalNetworksResources/training_guidance_material/webinars.html', new: '/engage-locally/manage/training'},
      {old: '/LocalNetworksResources/news_updates/index.html', new: '/engage-locally/manage/news'},
      {old: '/LocalNetworksResources/reports/index.html', new: '/engage-locally/manage/reports'},
      {old: '/LocalNetworksResources/reports/foundation_financial_statements.html', new: '/engage-locally/manage/reports/foundation'},
      {old: '/LocalNetworksResources/reports/outcome_documents.html', new: '/engage-locally/manage/reports/mtg-outcome'},
      {old: '/LocalNetworksResources/reports/local_network_annual_reports.html', new: '/engage-locally/manage/reports/local-network-report'},
      {old: '/LocalNetworksResources/reports/local_network_advisory_group_documents.html', new: '/engage-locally/manage/reports/local-networks-document'},
      {old: '/LocalNetworksResources/reports/un_global_compact_activity_reports.html', new: '/engage-locally/manage/reports/activity-report'},
      {old: '/AboutTheGC/tools_resources/index.html', new: '/library'},
      {old: '/resources', new: '/library'},
      {old: '/AboutTheGC/index.html', new: '/about'},
      {old: '/AboutTheGC/faq.html', new: '/about/faq'},
      {old: '/AboutTheGC/The_GC_Foundation.html', new: '/about/foundation'},
      {old: '/AboutTheGC/Internship_at_the_Global_Compact/index.html', new: '/about/opportunities'},
      {old: '/AboutTheGC/job_opportunities_with_the_global_compact.html', new: '/about/opportunities'},
      {old: '/AboutTheGC/contact_us.html', new: '/about/contact'},
      {old: '/AboutTheGC/stages_of_development.html', new: '/about/governance'},
      {old: '/AboutTheGC/The_Global_Compact_Board/index.html', new: '/about/governance/board'},
      {old: '/AboutTheGC/The_Global_Compact_Board/bios.html', new: '/about/governance/board/members'},
      {old: '/NetworksAroundTheWorld/local_network_advisory_group.html', new: '/about/governance/local-network-advisory-group'},
      {old: '/AboutTheGC/IntegrityMeasures/Integrity_Measures_FAQs.html', new: '/about/integrity-measures'},
      {old: '/AboutTheGC/Government_Support.html', new: '/about/government-recognition'},
      {old: '/AboutTheGC/Government_Support/general_assembly_resolutions.html', new: '/about/government-recognition/general-assembly-resolutions'},
      {old: '/AboutTheGC/Government_Support/recognition_by_the_g8.html', new: '/about/government-recognition/g8-recognition'},
      {old: '/AboutTheGC/Government_Support/outcomes_and_declarations.html', new: '/about/government-recognition/outcomes-declarations'},
      {old: '/NewsAndEvents/index.html', new: '/news'},
      {old: '/NewsAndEvents/UNGC_bulletin/index.html', new: '/news/bulletin'},
      {old: '/NewsAndEvents/UNGC_bulletin/subscribe_email_sent.html', new: '/news/bulletin'},
      {old: '/NewsAndEvents/UNGC_bulletin/unsubscribe.html', new: '/news/bulletin'},
      {old: '/NewsAndEvents/Speeches.html', new: '/news/speeches'},
      {old: '/NewsAndEvents/Global_Compact_in_the_Media.html', new: '/news/media'},
      {old: '/Languages/arabic/index.html', new: '/'},
      {old: '/Languages/chinese/index.html', new: '/'},
      {old: '/Languages/french/index.html', new: '/'},
      {old: '/Languages/russian/index.html', new: '/'},
      {old: '/Languages/spanish/index.html', new: '/'},
      {old: '/Languages/german/index.html', new: '/'},
      {old: '/Languages/portuguese/index.html', new: '/'},
      {old: '/WebsiteInfo/copyright.html', new: '/copyright'},
      {old: '/WebsiteInfo/privacy_policy.html', new: '/privacy-policy'},
      {old: '/NewsAndEvents/media_contacts.html', new: '/about/contact'},
      {old: '/resources/1171', new: '/library/1171'}
    ]

    @runs = 0
    @tests = 0
    @failures = []
  end

  def run
    print_starting

    @urls_to_redirect.each do |urls|
      response =  @conn.get(urls[:old])

      if response.headers["location"] == @dev_host + urls[:new]
        print_success

        response = @conn.get response.headers["location"]
        if response.status == 200
          print_success
        else
          add_new_url_status_code_error(urls,response.status)
          print_failure
        end
      else
        add_redirect_location_error(urls,response.headers["location"])
        print_failure
      end

      @runs = @runs+1
    end

    print_results
  end

  def add_redirect_location_error(urls, actual_url)
    @failures << "Failure: Expected GET #{urls[:old]} to redirect to #{urls[:new]}. Found #{actual_url}."
  end

  def add_new_url_status_code_error(urls,status)
    @failures << "Failure: Expected GET #{urls[:new]} to succeed with 200. Found #{status}."
  end

  def print_starting
    puts "\n"
  end

  def print_results
    puts "\n\n"

    unless @failures.empty?
      @failures.each do |error|
        puts error + "\n\n"
      end
    end

    puts "#{@runs} runs, #{@tests} tests, #{@failures.count} failures\n"
  end

  def print_success
    @tests = @tests+1
    print "."
  end

  def print_failure
    print "F"
  end
end
