module FixtureReplacement
  def random_url
    "/#{[String.random, String.random, String.random].join('/')}.html"
  end
  
  attributes_for :case_story do |a|
	end

  attributes_for :communication_on_progress do |a|
	end

  attributes_for :contact do |c|
    c.first_name = String.random
    c.last_name = String.random
    c.organization_id = Organization.first.id
	end

  attributes_for :content do |c|
  end
  
  attributes_for :content_template do |ct|
    ct.filename = random_url
    ct.label = String.random
  end
  
  attributes_for :content_versions do |cv|
    cv.path = random_url
    cv.content = "<h1>#{String.random}</h1><p>#{String.random}</p><p>#{String.random}</p>"
    cv.template = ContentTemplate.first
  end

  attributes_for :cop_score do |a|
    
  end

  attributes_for :cop_score do |a|
	end

  attributes_for :country do |a|
	end

  attributes_for :exchange do |a|
	end

  attributes_for :initiative do |a|
    a.name = String.random
  end

  attributes_for :interest do |a|
	end

  attributes_for :language do |a|
	end

  attributes_for :listing_status do |a|
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

  attributes_for :navigation do |n|
    n.label = String.random
    n.href  = String.random
  end

  attributes_for :organization_type do |o|
    o.name = String.random
    o.type_property = OrganizationType::BUSINESS
	end

  attributes_for :organization do |o|
    o.name = String.random
    o.organization_type_id = OrganizationType.first.try(:id)
	end

  attributes_for :principle do |a|
	end

  attributes_for :removal_reason do |a|
	end

  attributes_for :role do |a|
	end

  attributes_for :sector do |a|
	end
end