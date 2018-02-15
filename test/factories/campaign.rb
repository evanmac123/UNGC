FactoryBot.define do
  factory :campaign do
    name { Faker::Name.name }
    campaign_id { SecureRandom.uuid }
  end
end
