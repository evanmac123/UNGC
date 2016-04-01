module FixtureReplacement
  extend ActionDispatch::TestProcess

  def random_url
    "/#{[FixtureReplacement.random_string, FixtureReplacement.random_string, FixtureReplacement.random_string].join('/')}.html"
  end

  attributes_for :comment do |c|
    c.body = FixtureReplacement.random_string
  end

  attributes_for :communication_on_progress do |cop|
    cop.starts_on = Date.today - 1.year
    cop.ends_on = Date.today
    cop.title = FixtureReplacement.random_string
    cop.organization_id = Organization.first.id
    cop.contact_info = FixtureReplacement.random_string
    cop.include_actions = false
    cop.include_measurement = true
    cop.use_indicators = false
    cop.cop_score_id = new_cop_score.id
    cop.use_gri = true
    cop.has_certification = false
    cop.notable_program = true
    cop.description = FixtureReplacement.random_string
    cop.state = 'approved'
    cop.include_continued_support_statement = false
    cop.format = FixtureReplacement.random_string
    cop.references_human_rights = true
    cop.references_labour = false
    cop.references_environment = true
    cop.references_anti_corruption = false
    cop.meets_advanced_criteria = true
    cop.additional_questions = false
    cop.method_shared = FixtureReplacement.random_string
    cop.differentiation = FixtureReplacement.random_string
    cop.references_business_peace = true
    cop.references_water_mandate = false
  end

  attributes_for :contact do |c|
    c.first_name = FixtureReplacement.random_string
    c.last_name = FixtureReplacement.random_string
    c.prefix = %w{Mr. Ms. Mrs.}[rand(3)]
    c.job_title = FixtureReplacement.random_string
    c.phone = FixtureReplacement.random_string
    c.address = FixtureReplacement.random_string
    c.city = FixtureReplacement.random_string
    c.country = create_country
    c.email = FixtureReplacement.random_string + '@example.com'
    c.username = FixtureReplacement.random_string
    c.password = FixtureReplacement.random_string
  end

  attributes_for :cop_question do |q|
    q.text = FixtureReplacement.random_string
    q.principle_area_id = PrincipleArea.first.id
    q.grouping = 'additional'
    q.position = 1
  end

  attributes_for :cop_link do |l|
    l.attachment_type = CopFile::TYPES[:cop]
    l.url = "http://#{FixtureReplacement.random_string}.org"
    l.language = create_language
    l.communication_on_progress = new_communication_on_progress
  end

  attributes_for :cop_attribute do |a|
    a.text  = FixtureReplacement.random_string
    a.hint  = FixtureReplacement.random_string
  end

  attributes_for :cop_answer do |a|
    a.text  = FixtureReplacement.random_string
  end

  attributes_for :cop_score do |a|
  end

  attributes_for :country do |c|
    c.name = FixtureReplacement.random_string
    c.region = 'Americas'
    c.code = FixtureReplacement.random_string
  end

  attributes_for :event do |e|
    e.title = FixtureReplacement.random_string
    e.description = FixtureReplacement.random_string
    e.thumbnail_image = fixture_file_upload([Rails.root, 'test/fixtures/files/untitled.jpg'].join('/'), 'image/jpeg')
    e.banner_image = fixture_file_upload([Rails.root, 'test/fixtures/files/untitled.jpg'].join('/'), 'image/jpeg')
  end

  attributes_for :sponsor do |e|
    e.name = FixtureReplacement.random_string
  end

  attributes_for :searchable_event, class:Event do |e|
    e.title = FixtureReplacement.random_string
    e.location = FixtureReplacement.random_string
    e.description = FixtureReplacement.random_string
  end

  attributes_for :exchange do |a|
  end

  attributes_for :headline do |a|
    a.title = FixtureReplacement.random_string
    a.description = "<p>#{FixtureReplacement.random_string}</p>"
    a.published_on = Time.now
  end

  attributes_for :initiative do |a|
    a.name = FixtureReplacement.random_string
  end

  attributes_for :interest do |a|
  end

  attributes_for :language do |l|
    l.name = FixtureReplacement.random_string
  end

  attributes_for :listing_status do |l|
    l.name = FixtureReplacement.random_string
  end

  attributes_for :local_network do |l|
    l.name = FixtureReplacement.random_string
    l.funding_model = LocalNetwork::FUNDING_MODELS.keys.shuffle.first.to_s
  end

  attributes_for :logo_approval do |a|
  end

  attributes_for :logo_comment do |a|
  end

  attributes_for :logo_file do |f|
    f.name = FixtureReplacement.random_string
    f.thumbnail = FixtureReplacement.random_string
    f.file = FixtureReplacement.random_string
  end

  attributes_for :logo_publication do |p|
    p.name = FixtureReplacement.random_string
  end

  attributes_for :logo_request do |r|
    r.purpose = FixtureReplacement.random_string
    r.organization_id = Organization.first.id
    r.contact_id = Contact.first.id
    r.publication_id = LogoPublication.first.id
  end

  attributes_for :organization_type do |o|
    o.name = FixtureReplacement.random_string
    o.type_property = OrganizationType::BUSINESS
  end

  attributes_for :organization do |o|
    o.name = FixtureReplacement.random_string
    o.organization_type = default_business_organization_type
    o.employees = 500
    o.url = 'http://www.example.com'
    o.pledge_amount = 1000
    o.joined_on = Date.new(2009,10,10)
  end

  attributes_for :business, class: Organization do |o|
    o.name = random_string
    o.organization_type = default_business_organization_type
    o.employees = 500
    o.url = 'http://www.example.com'
    o.pledge_amount = 1000
    o.joined_on = Date.new(2009,10,10)
    o.active = true
    o.participant = true
    o.state = Organization::STATE_APPROVED
    o.cop_state = Organization::COP_STATE_ACTIVE
  end

  attributes_for :non_business, class: Organization do |o|
    o.name = random_string
    o.organization_type = new_organization_type(type_property: OrganizationType::NON_BUSINESS)
    o.employees = 500
    o.url = 'http://www.example.com'
    o.pledge_amount = 1000
    o.joined_on = Date.new(2009,10,10)
    o.active = true
    o.participant = true
    o.state = Organization::STATE_APPROVED
    o.cop_state = Organization::COP_STATE_ACTIVE
  end

  def default_business_organization_type
    OrganizationType.company || create_organization_type(
      name: OrganizationType::FILTERS[:companies],
      type_property: OrganizationType::BUSINESS
    )
  end

  attributes_for :principle do |a|
    a.name = FixtureReplacement.random_string
  end

  attributes_for :principle_area do |a|
    a.name = FixtureReplacement.random_string
  end

  attributes_for :removal_reason do |a|
  end

  attributes_for :role do |r|
    r.name = FixtureReplacement.random_string
    r.description = FixtureReplacement.random_string
  end

  attributes_for :sector do |s|
    s.name = FixtureReplacement.random_string
  end

  attributes_for :signing do |s|
    s.added_on = Date.today
  end

  attributes_for :sustainable_development_goal do |s|
    s.goal_number = rand(100)
    s.name = "Goal: #{FixtureReplacement.random_string}"
  end

  attributes_for :resource do |r|
    r.title = FixtureReplacement.random_string
    r.description = FixtureReplacement.random_string
  end

  attributes_for :author do |a|
  end

  attributes_for :resource_link do |l|
    l.resource = Resource.first || create_resource
    l.language = Language.first || create_language
    l.title = FixtureReplacement.random_string
    l.link_type = ResourceLink::TYPES.keys.shuffle.first.to_s
  end

  attributes_for :cop_file do |c|
    c.language = create_language
    c.attachment_type = CopFile::TYPES[:cop]
  end

  attributes_for :grace_letter, class:CommunicationOnProgress do |g|
    g.organization = Organization.first
    g.title = 'Grace Letter'
    g.format = CopFile::TYPES[:grace_letter]
  end

  attributes_for :reporting_cycle_adjustment, class:CommunicationOnProgress do |g|
    g.organization = Organization.first
    g.title = 'Reporting Cycle Adjustment'
    g.format = CopFile::TYPES[:reporting_cycle_adjustment]
  end

  attributes_for :communication do |c|
    c.title = FixtureReplacement.random_string
    c.date = Date.new(2010, 1, 1)
  end

  attributes_for :announcement do |a|
    a.title = FixtureReplacement.random_string
    a.description = FixtureReplacement.random_string
    a.date = Date.new(2010, 1, 1)
  end

  attributes_for :annual_report do |a|
  end

  attributes_for :award do |a|
    a.title = FixtureReplacement.random_string
    a.description = FixtureReplacement.random_string
    a.date = Date.new(2010, 1, 1)
  end

  attributes_for :integrity_measure do |i|
    i.title = FixtureReplacement.random_string
    i.description = FixtureReplacement.random_string
    i.date = Date.new(2010, 1, 1)
  end

  attributes_for :local_network_event do |l|
    l.title = FixtureReplacement.random_string
    l.description = FixtureReplacement.random_string
    l.event_type = FixtureReplacement.random_string
    l.date = Date.new(2010, 1, 1)
    l.num_participants = 10
    l.gc_participant_percentage = 100
  end

  attributes_for :meeting do |m|
    m.date = Date.new(2010, 1, 1)
  end

  attributes_for :mou do |m|
  end

  attributes_for :campaign do |c|
    c.campaign_id = FixtureReplacement.random_string(15)
    c.name = FixtureReplacement.random_string
  end

  attributes_for :contribution do |c|
    c.id = FixtureReplacement.random_string(16)
    c.date = Date.today - rand(999).days
    c.stage = FixtureReplacement.random_string
    c.organization_id = create_organization.id
    c.contribution_id = FixtureReplacement.random_string(16)
  end

  attributes_for :principle do |p|
    p.name = FixtureReplacement.random_string
  end

  attributes_for :issue_area do |i|
    i.name = FixtureReplacement.random_string
  end

  attributes_for :issue do |i|
    i.name = FixtureReplacement.random_string
  end

  attributes_for :topic do |t|
    t.name = FixtureReplacement.random_string
  end

  attributes_for :container, class: Container do |c|
    c.layout = :home
    c.slug = FixtureReplacement.random_string
  end

  attributes_for :payload, class: Payload do |p|
    p.container_id = new_container.id
    p.json_data = '{}'
  end

  attributes_for :non_business_registration, class: NonBusinessOrganizationRegistration do |r|
    r.date = rand(3.years).seconds.ago
    r.place = random_string
    r.authority = random_string
    r.mission_statement = random_string
    r.number = random_string
  end

  attributes_for :sdg_pioneer_submission, class: SdgPioneer::Submission do |s|
    s.pioneer_type = 0
    s.global_goals_activity = FixtureReplacement.random_string
    s.matching_sdgs = [create_sustainable_development_goal.id]
    s.name = FixtureReplacement.random_string
    s.title = FixtureReplacement.random_string
    s.email = FixtureReplacement.random_string
    s.phone = FixtureReplacement.random_string
    s.organization_name = create_business.name
    s.organization_name_matched = true
    s.country_name = create_country.name
    s.reason_for_being = FixtureReplacement.random_string
    s.accepts_tou = true
    s.supporting_documents.build
  end

  attributes_for :sdg_pioneer_other, class: SdgPioneer::Other do |o|
    o.organization_type = 'un'
    o.sdg_pioneer_role = 'change_makers'
    o.submitter_name = FixtureReplacement.random_string
    o.submitter_place_of_work = FixtureReplacement.random_string
    o.submitter_job_title = FixtureReplacement.random_string
    o.submitter_email = FixtureReplacement.random_string
    o.submitter_phone = FixtureReplacement.random_string
    o.nominee_name = FixtureReplacement.random_string
    o.nominee_work_place = FixtureReplacement.random_string
    o.nominee_email = FixtureReplacement.random_string
    o.nominee_phone = FixtureReplacement.random_string
    o.nominee_title = FixtureReplacement.random_string
    o.why_nominate = FixtureReplacement.random_string
    o.accepts_tou = true
  end

  attributes_for :express_cop do |c|
    c.organization = create_organization(employees: 11)
    c.endorses_ten_principles = true
    c.covers_issue_areas = true
    c.measures_outcomes = true
  end

end
