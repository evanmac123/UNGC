FactoryGirl.define do
  factory :integrity_measure do
    attachment { build(:uploaded_file) }
    date { Faker::Date.forward(20) }
    description { Faker::Lorem.paragraph }
    title { Faker::Lorem.sentence }
  end
end
