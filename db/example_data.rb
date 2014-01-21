module FixtureReplacement
  def random_url
    "/#{[FixtureReplacement.random_string, FixtureReplacement.random_string, FixtureReplacement.random_string].join('/')}.html"
  end

  attributes_for :case_story do |c|
    c.title = FixtureReplacement.random_string
  end

  attributes_for :comment do |c|
    c.body = FixtureReplacement.random_string
  end

  attributes_for :communication_on_progress do |cop|
    cop.starts_on = Date.today - 1.year
    cop.ends_on = Date.today
    cop.title = FixtureReplacement.random_string
    cop.organization_id = Organization.first.id
    cop.email = FixtureReplacement.random_string
    cop.job_title = FixtureReplacement.random_string
    cop.contact_name = FixtureReplacement.random_string
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
    c.prefix = FixtureReplacement.random_string
    c.job_title = FixtureReplacement.random_string
    c.phone = FixtureReplacement.random_string
    c.address = FixtureReplacement.random_string
    c.city = FixtureReplacement.random_string
    c.country_id = Country.first.id
    c.email = FixtureReplacement.random_string + '@example.com'
    c.username = FixtureReplacement.random_string
    c.plaintext_password = FixtureReplacement.random_string
    c.password = c.plaintext_password
  end

  attributes_for :cop_question do |q|
    q.text = FixtureReplacement.random_string
    q.principle_area_id = PrincipleArea.first.id
    q.grouping = 'additional'
    q.position = 1
  end

  attributes_for :cop_attribute do |a|
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
    o.organization_type_id = OrganizationType.first.id
    o.employees = 500
    o.url = 'http://www.example.com'
    o.pledge_amount = 1000
    o.joined_on = Date.new(2009,10,10)
  end

  attributes_for :page do |a|
    a.path      = random_url
    a.title     = FixtureReplacement.random_string
    a.html_code = FixtureReplacement.random_string
    a.approval  = 'approved'
    a.display_in_navigation = true
  end

  attributes_for :page_group do |a|
    a.name      = FixtureReplacement.random_string
    a.html_code = FixtureReplacement.random_string

    a.display_in_navigation = true
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
    g.title = FixtureReplacement.random_string
    g.format = CopFile::TYPES[:reporting_cycle_adjustment]
  end
end
