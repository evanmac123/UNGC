FactoryBot.define do
  factory :communication do
    title { Faker::Lorem.sentence }
    date { Faker::Date.forward(20) }
    attachment { build(:uploaded_file) }
  end
end
