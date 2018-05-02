FactoryBot.define do
  factory :sdg_pioneer_submission, :class => SdgPioneer::Submission do
    country_name { create(:country).name }
    organization_name Faker::Company.name
    is_participant Faker::Boolean.boolean
    name Faker::Name.name
    title Faker::Name.title
    email Faker::Internet.email
    phone Faker::PhoneNumber.phone_number
    pioneer_type :business_leader
    website_url Faker::Internet.url
    reason_for_being { Faker::Lorem.paragraph }
    company_success { Faker::Lorem.paragraph }
    innovative_sdgs { Faker::Lorem.paragraph }
    ten_principles { Faker::Lorem.paragraph }
    awareness_and_mobilize { Faker::Lorem.paragraph }
    matching_sdgs { create_list(:sustainable_development_goal, 2).map(&:id) }
    # other_relevant_info Faker::Lorem.paragraph
    # local_business_name Faker::Company.name
    # is_nominated Faker::Boolean.boolean
    # nominating_organization Faker::Company.name
    # nominating_individual Faker::Name.name
    has_local_network true
    local_network_question Faker::Lorem.paragraph
    accepts_interview true
    organization_name_matched true
    accepts_tou true
    after(:build) do |o|
      o.supporting_documents.build
    end
  end
end
