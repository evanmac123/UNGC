FactoryGirl.define do
  factory :issue do
    name { Faker::Name.name }
  end
end
