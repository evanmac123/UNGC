FactoryGirl.define do
  factory :role do
    name Faker::Name.name
    description Faker::Lorem.sentence
  end
end
