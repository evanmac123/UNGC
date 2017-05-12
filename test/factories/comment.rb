FactoryGirl.define do
  factory :comment do
    body { Faker::Lorem.paragraph }
    association :contact, factory: :contact
  end
end
