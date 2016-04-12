FactoryGirl.define do
  factory :topic do
    name { Faker::Name.name }
  end
end
