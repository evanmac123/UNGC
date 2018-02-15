FactoryBot.define do
  factory :headline do
    title { Faker::Lorem.sentence }
  end
end
