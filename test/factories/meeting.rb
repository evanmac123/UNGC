FactoryBot.define do
  factory :meeting do
    date { Faker::Date.forward(20) }
    attachment { build(:uploaded_file) }
  end
end
