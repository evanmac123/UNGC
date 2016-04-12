FactoryGirl.define do
  factory :non_business_organization_registration do
    date { Date.today }
    place { Faker::Address.city }
    authority { Faker::Name.name }
    mission_statement { Faker::Lorem.sentence }
  end
end
