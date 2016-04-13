FactoryGirl.define do
  factory :contribution do
    organization
    contribution_id { SecureRandom.uuid }
    date { Faker::Date.forward(20) }
    stage { Faker::Lorem.word }
  end
end
