FactoryGirl.define do
  factory :non_business_organization_registration do
    date { Date.current }
    place { Faker::Address.city }
    authority { Faker::Name.name }
    mission_statement { Faker::Lorem.sentence }
  end
end
