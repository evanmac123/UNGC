FactoryGirl.define do
  factory :sustainable_development_goal do
    name { Faker::Name.name }
    sequence(:goal_number)
  end
end
