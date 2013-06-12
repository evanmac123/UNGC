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

  attributes_for :cop_score do |a|
	end

  attributes_for :country do |c|
    c.name = FixtureReplacement.random_string
    c.region = 'Americas'
    c.code = FixtureReplacement.random_string
	end

  attributes_for :event do |a|
    a.title = FixtureReplacement.random_string
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

  attributes_for :listing_status do |a|
	end

  attributes_for :local_network do |l|
    l.name = FixtureReplacement.random_string
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
end
