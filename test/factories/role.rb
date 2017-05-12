FactoryGirl.define do
  factory :role do
    name Faker::Name.name
    description Faker::Lorem.sentence

    trait :integrity_team_member do
      name 'Integrity Team Member'
    end

    trait :integrity_manager do
      name 'Integrity Manager'
    end
  end
end
