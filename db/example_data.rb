module FixtureReplacement
  def random_url
    "/#{[String.random, String.random, String.random].join('/')}.html"
  end
  
  attributes_for :case_story do |c|
    c.title = String.random
	end

  attributes_for :comment do |c|
    c.body = String.random
  end

  attributes_for :communication_on_progress do |cop|
    cop.starts_on = Date.today - 1.year
    cop.ends_on = Date.today
    cop.title = String.random
  end

  attributes_for :contact do |c|
    c.first_name = String.random
    c.last_name = String.random
    c.prefix = String.random
    c.job_title = String.random
    c.phone = String.random
    c.address = String.random
    c.city = String.random
    c.country_id = Country.first.id
    c.email = String.random + '@example.com' 
    c.login = String.random
    c.password = String.random
	end

  attributes_for :cop_question do |q|
    q.text = String.random
    q.principle_area_id = PrincipleArea.first.id
    q.grouping = 'additional'
    q.position = 1
  end

  attributes_for :cop_score do |a|
	end

  attributes_for :country do |c|
    c.name = String.random
    c.region = 'Americas'
    c.code = String.random
	end

  attributes_for :event do |a|
    a.title = String.random
  end

  attributes_for :exchange do |a|
	end

  attributes_for :headline do |a|
    a.title = String.random
  end

  attributes_for :initiative do |a|
    a.name = String.random
  end

  attributes_for :interest do |a|
	end

  attributes_for :language do |l|
    l.name = String.random
	end

  attributes_for :listing_status do |a|
	end

  attributes_for :local_network do |l|
    l.name = String.random
  end

  attributes_for :logo_approval do |a|
  end

  attributes_for :logo_comment do |a|
	end

  attributes_for :logo_file do |f|
    f.name = String.random
    f.thumbnail = String.random
    f.file = String.random
	end

  attributes_for :logo_publication do |p|
    p.name = String.random
	end

  attributes_for :logo_request do |r|
    r.purpose = String.random
    r.organization_id = Organization.first.id
    r.contact_id = Contact.first.id
    r.publication_id = LogoPublication.first.id
	end

  attributes_for :organization_type do |o|
    o.name = String.random
    o.type_property = OrganizationType::BUSINESS
	end

  attributes_for :organization do |o|
    o.name = String.random
    o.organization_type_id = OrganizationType.first.id
    o.employees = 500
    o.url = 'http://www.example.com'
    o.pledge_amount = 1000
    o.joined_on = Date.new(2009,10,10)
	end

  attributes_for :page do |a|
    a.path      = random_url
    a.title     = String.random
    a.html_code = String.random
    a.approval  = 'approved'
    a.display_in_navigation = true
  end
  
  attributes_for :page_group do |a|
    a.name      = String.random
    a.html_code = String.random

    a.display_in_navigation = true
  end

  attributes_for :principle do |a|
    a.name = String.random
	end

  attributes_for :principle_area do |a|
    a.name = String.random
	end

  attributes_for :removal_reason do |a|
	end

  attributes_for :role do |r|
    r.name = String.random
    r.description = String.random
	end

  attributes_for :sector do |s|
    s.name = String.random
	end

  attributes_for :signing do |s|
    s.added_on = Date.today
  end
end