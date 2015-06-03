desc 'sadness'

task :redirect_test do
  RedirectTest.new.run
end

class RedirectTest
  def initialize
    @dev_host = 'http://localhost:5000'
    @conn = Faraday.new(url: @dev_host)

    @urls_to_redirect = [
      {old: '/Issues/index.html', new: '/take-action'},
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
      {old: '/AboutTheGC/IntegrityMeasures/index.html', new: '/what-is-gc/our-commitment'},
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
      {old: '/Issues/transparency_anticorruption/collective_action.html', new: '/what-is-gc/our-work/governance/anti-corruption/collective-action'},
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
      {old: '/COPs/advanced/143311', new: '/participation/report/cop/create-and-submit/advanced/143311'}
    ]

    @runs = 0
    @tests = 0
    @failures = []
  end

  def run
    print_starting

    @urls_to_redirect.each do |urls|
      response =  @conn.get(urls[:old])

      if response.status == 301
        print_success
      else
        add_redirect_status_code_error(urls,response.status) unless response.status == 301
        print_failure
      end

      if response.headers["location"] == @dev_host + urls[:new]
        print_success
      else
        add_redirect_location_error(urls,response.headers["location"])
        print_failure
      end

      response = @conn.get response.headers["location"]
      if response.status == 200
        print_success
      else
        add_new_url_status_code_error(urls,response.status)
        print_failure
      end

      @runs = @runs+1
    end

    print_results
  end

  def add_redirect_status_code_error(urls, status)
    @failures << "Failure: Expected GET #{urls[:old]} to redirect with 301. Found #{status}."
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
