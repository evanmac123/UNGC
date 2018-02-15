FactoryBot.define do
  factory :resource do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
  end
end
