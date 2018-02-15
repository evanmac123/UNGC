FactoryBot.define do
  factory :announcement do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    date { Faker::Date.forward(20) }
  end
end
