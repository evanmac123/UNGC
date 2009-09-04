module FixtureReplacement
  attributes_for :case_story do |a|
	end

  attributes_for :communication_on_progress do |a|
	end

  attributes_for :contact do |c|
    c.first_name = String.random
    c.last_name = String.random
	end

  attributes_for :cop_score do |a|
	end

  attributes_for :country do |a|
	end

  attributes_for :exchange do |a|
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

  attributes_for :logo_file do |a|
	end

  attributes_for :logo_publication do |p|
    p.name = String.random
	end

  attributes_for :logo_request do |r|
    r.purpose = String.random
	end

  attributes_for :navigation do |n|
    n.label = String.random
    n.href  = String.random
  end

  attributes_for :organization_type do |a|
	end

  attributes_for :organization do |o|
    o.name = 'Unspace'
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