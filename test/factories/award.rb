FactoryBot.define do
  factory :award do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    date { Faker::Date.forward(20) }
    attachment { build(:uploaded_file) }
  end
end
